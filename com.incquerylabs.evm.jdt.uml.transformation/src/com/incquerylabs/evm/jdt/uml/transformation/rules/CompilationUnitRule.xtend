package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.CompilationUnitFilter
import org.apache.log4j.Level
import com.incquerylabs.evm.jdt.JDTEventAtom
import javax.management.RuntimeErrorException
import com.incquerylabs.evm.jdt.uml.transformation.rules.visitors.TypeVisitor

class CompilationUnitRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val IUMLManipulator umlManipulator
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, IUMLManipulator umlManipulator) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlManipulator = umlManipulator
		this.filter = new CompilationUnitFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(JDTJobFactory.createJob(JDTActivationState.APPEARED)[activation, context |
			val atom = activation.atom
			debug('''Compilation unit appeared: «atom.element»''')
			atom.transform
		])
		
		jobs.add(JDTJobFactory.createJob(JDTActivationState.DISAPPEARED)[activation, context |
			debug('''Compilation unit disappeared: «activation.atom.element»''')
			
		])
		
		jobs.add(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
			debug('''Compilation unit updated: «activation.atom.element»''')
			
		])
	}
	
	def transform(JDTEventAtom atom) {
		val element = atom.element
		val delta = atom.delta
		val ast = delta.compilationUnitAST
		if(ast == null) {
			error('''AST was null, compilation unit is not transformed: «element»''')
			return
		}
		val typeVisitor = new TypeVisitor(umlManipulator)
		ast.accept(typeVisitor)
		
		return
	}
	
}
