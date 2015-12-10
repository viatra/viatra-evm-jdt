package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IType
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName

class ClassRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val IUMLManipulator umlManipulator
	
	new(
		JDTEventSourceSpecification eventSourceSpecification, 
		ActivationLifeCycle activationLifeCycle, 
		IJavaProject project, 
		IUMLManipulator umlManipulator
	) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlManipulator = umlManipulator
		logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(JDTJobFactory.createJob(JDTActivationState.APPEARED)[activation, context |
			val javaClass = activation.atom
			if(javaClass instanceof IType){
				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
				createClass(umlQualifiedName)
			}
		])
		jobs.add(JDTJobFactory.createJob(JDTActivationState.DISAPPEARED)[activation, context |
			val javaClass = activation.atom
			if(javaClass instanceof IType){
				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
				deleteClass(umlQualifiedName)
			}
		])
		jobs.add(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
			val javaClass = activation.atom
			if(javaClass instanceof IType){
				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
//				updateName(umlQualifiedName)
			}
		])
	}
	
}