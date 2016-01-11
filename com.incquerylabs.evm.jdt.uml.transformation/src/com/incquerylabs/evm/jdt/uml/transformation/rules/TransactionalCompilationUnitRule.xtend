package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.google.common.collect.ImmutableList
import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.transactions.JDTTransactionalActivationState
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.CompilationUnitFilter
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.CrossReferenceUpdateVisitor
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.TypeVisitor
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.Optional
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.specific.Jobs
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTNode
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Interface
import org.eclipse.uml2.uml.StructuredClassifier

class TransactionalCompilationUnitRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val UMLModelAccess umlModelAccess
	val TypeVisitor typeVisitor
	val CrossReferenceUpdateVisitor crossReferenceUpdateVisitor
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, UMLModelAccess umlModelAccess, JDTJobFactory jobFactory) {
		super(eventSourceSpecification, activationLifeCycle, project, jobFactory)
		this.umlModelAccess = umlModelAccess
		this.typeVisitor = new TypeVisitor(umlModelAccess)
		this.crossReferenceUpdateVisitor = new CrossReferenceUpdateVisitor(umlModelAccess)
		this.filter = new CompilationUnitFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(Jobs.newEnableJob(createJob(JDTTransactionalActivationState.DELETED)[activation, context |
			debug('''Compilation unit is deleted: «activation.atom.element»''')
			try {
				val compilationUnit = activation.atom.element as ICompilationUnit
				compilationUnit.deleteCorrespondingType
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		]))
		
		jobs.add(Jobs.newEnableJob(createJob(JDTTransactionalActivationState.COMMITTED)[activation, context |
			val atom = activation.atom
			debug('''Compilation unit is modified: «activation.atom.element»''')
			try{
				atom.transform
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		]))
		
		jobs.add(Jobs.newEnableJob(createJob(JDTTransactionalActivationState.DEPENDENCY_UPDATED)[activation, context |
			val atom = activation.atom
			debug('''Cross references are updated in compilation unit: «activation.atom.element»''')
			try{
				atom.updateCrossReferences
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit cross references''', e)
			}
		]))
	}
	
	def transform(JDTEventAtom atom) {
		val element = atom.element as ICompilationUnit
		val optionalDelta = atom.delta
		var ASTNode ast
		if(!optionalDelta.present) {
			debug('''Delta was not present in the event atom: «element»''')
			ast = element.ast
		} else {
			ast = optionalDelta.map[ delta |
				delta.ast
			].orElseThrow[
				new IllegalStateException('''AST was null, compilation unit is not transformed: «element»''')
			]
		}
		typeVisitor.clearVisitedElements
		ast.accept(typeVisitor)
		
		val visitedElements = typeVisitor.visitedElements
		val visitedClasses = visitedElements.filter(Class)
		val operationsOfVisitedClasses = visitedClasses.map[
			ownedOperations
		].flatten
		val associationsOfVisitedClasses = visitedClasses.map[
			getAssociationsOf(it)
		].flatten
		val operationsToRemove = ImmutableList::copyOf(operationsOfVisitedClasses.filter[
			!visitedElements.contains(it)
		])
		val associationsToRemove = ImmutableList::copyOf(associationsOfVisitedClasses.filter[
			!visitedElements.contains(it)
		])
		operationsToRemove.forEach[
			removeOperation
		]
		associationsToRemove.forEach[
			removeAssociation
		]
		
		return
	}
	
	def deleteCorrespondingType(ICompilationUnit element) {
		val umlQualifiedName = element.getUmlClassQualifiedName
		val umlClass = findType(umlQualifiedName)
		umlClass.ifPresent[
			if(it instanceof StructuredClassifier){
				val associations = ImmutableList::copyOf(getAssociationsOf(it))
				associations.forEach[
					removeAssociation
				]
			}
		]
		
		umlClass.ifPresent[
			if(it instanceof Interface){
				removeInterface
			} else if(it instanceof Class){
				removeClass
			}
		]
	}
	
	private def getAssociationsOf(StructuredClassifier umlClass) {
		val associations = umlClass.ownedAttributes.map[ attribute |
			Optional::ofNullable(attribute.association)
		].filter[isPresent].map[get]
		
		return associations
	}
	
	def updateCrossReferences(JDTEventAtom atom) {
		val element = atom.element as ICompilationUnit
		val ast = element.ast
		ast.accept(crossReferenceUpdateVisitor)
		return
	}
	
	def getUmlClassQualifiedName(ICompilationUnit compilationUnit) {
		val packageFragment = compilationUnit.parent
		if(!(packageFragment instanceof IPackageFragment)) {
			throw new IllegalArgumentException('''Compilation unit is not in a package: «compilationUnit»''')
		}
		val javaQualifiedName = JDTQualifiedName::create('''«packageFragment.elementName».«compilationUnit.elementName»''').parent.get
		val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
		return umlQualifiedName
	}
	
	private def getAst(IJavaElementDelta delta) {
		val element = delta.element
		val ast = delta.compilationUnitAST
		if(ast != null) {
			return ast
		}
		return element.ast
	}
	
	private def getAst(IJavaElement element) {
		if(element instanceof ICompilationUnit) {
			return element.parse
		}
	}
	
	private def ASTNode parse(ICompilationUnit compilationUnit) {
		val parser = ASTParser.newParser(AST.JLS8)
		parser.kind = ASTParser.K_COMPILATION_UNIT
		parser.source = compilationUnit
		parser.resolveBindings = true
		debug('''Manually parsed AST of «compilationUnit.elementName»''')
		return parser.createAST(null)
	}
}
