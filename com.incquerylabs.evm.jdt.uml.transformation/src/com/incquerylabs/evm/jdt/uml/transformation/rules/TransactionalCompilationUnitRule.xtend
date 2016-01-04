package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.transactions.JDTTransactionalActivationState
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.CompilationUnitFilter
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.TypeVisitor
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTNode
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.IJavaElement
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.CrossReferenceUpdateVisitor

class TransactionalCompilationUnitRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val IUMLManipulator umlManipulator
	val TypeVisitor typeVisitor
	val CrossReferenceUpdateVisitor crossReferenceUpdateVisitor
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, IUMLManipulator umlManipulator) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlManipulator = umlManipulator
		this.typeVisitor = new TypeVisitor(umlManipulator)
		this.crossReferenceUpdateVisitor = new CrossReferenceUpdateVisitor(umlManipulator)
		this.filter = new CompilationUnitFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(JDTJobFactory.createJob(JDTTransactionalActivationState.DELETED)[activation, context |
			debug('''Compilation unit is deleted: «activation.atom.element»''')
			try {
				val compilationUnit = activation.atom.element as ICompilationUnit
				compilationUnit.deleteCorrespondingElements
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		])
		
		jobs.add(JDTJobFactory.createJob(JDTTransactionalActivationState.COMMITTED)[activation, context |
			val atom = activation.atom
			debug('''Compilation unit is modified: «activation.atom.element»''')
			try{
				atom.transform
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		])
		
		jobs.add(JDTJobFactory.createJob(JDTTransactionalActivationState.DEPENDENCY_UPDATED)[activation, context |
			val atom = activation.atom
			debug('''Cross references are updated in compilation unit: «activation.atom.element»''')
			try{
				atom.updateCrossReferences
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit cross references''', e)
			}
		])
	}
	
	def transform(JDTEventAtom atom) {
		val element = atom.element as ICompilationUnit
		val optionalDelta = atom.delta
		if(!optionalDelta.present) {
			debug('''Delta was not present in the event atom, compilation unit is not transformed: «element»''')
			return
		}
		val ast = optionalDelta.map[ delta |
			delta.ast
		].orElseThrow[
			new IllegalStateException('''AST was null, compilation unit is not transformed: «element»''')
		]
		element.deleteCorrespondingElements
		ast.accept(typeVisitor)
		
		return
	}
	
	def updateCrossReferences(JDTEventAtom atom) {
		val element = atom.element as ICompilationUnit
		val ast = element.ast
		element.deleteReferencesOfClass
		ast.accept(crossReferenceUpdateVisitor)
		return
	}
	
	def deleteCorrespondingElements(ICompilationUnit element) {
		val umlQualifiedName = element.getUmlClassQualifiedName
		deleteClassAndReferences(umlQualifiedName)
	}
	
	def deleteCorrespondingClass(ICompilationUnit element) {
		val umlQualifiedName = element.getUmlClassQualifiedName
		deleteClass(umlQualifiedName)
	}
	
	def deleteReferencesOfClass(ICompilationUnit element) {
		val umlQualifiedName = element.getUmlClassQualifiedName
		deleteReferencesOfClass(umlQualifiedName)
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
