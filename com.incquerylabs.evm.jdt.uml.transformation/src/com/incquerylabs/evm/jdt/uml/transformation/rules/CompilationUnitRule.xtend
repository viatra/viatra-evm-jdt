package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.CompilationUnitFilter
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.TypeVisitor
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment

class CompilationUnitRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val UMLModelAccess umlModelAccess
	val TypeVisitor typeVisitor
	
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, UMLModelAccess umlModelAccess) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlModelAccess = umlModelAccess
		this.typeVisitor = new TypeVisitor(umlModelAccess)
		this.filter = new CompilationUnitFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(createJob(JDTActivationState.APPEARED)[activation, context |
			val atom = activation.atom
			debug('''Compilation unit appeared: «atom.element»''')
		])
		
		jobs.add(createJob(JDTActivationState.DISAPPEARED)[activation, context |
			debug('''Compilation unit disappeared: «activation.atom.element»''')
			try {
				val compilationUnit = activation.atom.element as ICompilationUnit
				compilationUnit.deleteCorrespondingClass
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		])
		
		jobs.add(createJob(JDTActivationState.UPDATED)[activation, context |
			val atom = activation.atom
			debug('''Compilation unit updated: «activation.atom.element»''')
			try{
				atom.transform
			} catch (IllegalArgumentException e) {
				error('''Error during updating compilation unit''', e)
			}
		])
	}
	
	def transform(JDTEventAtom atom) {
		val element = atom.element as ICompilationUnit
		val optionalDelta = atom.delta
		if(!optionalDelta.present){
			debug('''Delta was not present in the event atom, compilation unit is not transformed: «element»''')
			return
		}
		val delta = optionalDelta.get
		var ast = delta.compilationUnitAST
		if(delta.flags.bitwiseAnd(IJavaElementDelta.F_AST_AFFECTED) != 0) {
			if(ast == null) {
				throw new IllegalArgumentException('''AST was null, compilation unit is not transformed: «element»''')
			}
			ast.accept(typeVisitor)
		}
		
		return
	}
	
	def deleteCorrespondingClass(ICompilationUnit element) {
		val umlQualifiedName = element.getUmlClassQualifiedName
		val umlClass = findClass(umlQualifiedName)
		umlClass.ifPresent[
			removeClass
		]
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
	
}
