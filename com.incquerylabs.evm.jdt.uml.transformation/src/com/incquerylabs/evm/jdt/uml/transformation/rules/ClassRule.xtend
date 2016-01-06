package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IType

class ClassRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val UMLModelAccess umlModelAccess
	
	new(
		JDTEventSourceSpecification eventSourceSpecification, 
		ActivationLifeCycle activationLifeCycle, 
		IJavaProject project, 
		UMLModelAccess umlModelAccess
	) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlModelAccess = umlModelAccess
		logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(createJob(JDTActivationState.APPEARED)[activation, context |
			val javaClass = activation.atom.element
			if(javaClass instanceof IType){
				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
				ensureClass(umlQualifiedName)
			}
		])
		jobs.add(createJob(JDTActivationState.DISAPPEARED)[activation, context |
			val javaClass = activation.atom.element
			if(javaClass instanceof IType){
				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
				val umlClass = findClass(umlQualifiedName)
				umlClass.ifPresent[
					removeClass
				]
			}
		])
//		jobs.add(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
//			val javaClass = activation.atom
//			if(javaClass instanceof IType){
//				val javaQualifiedName = JDTQualifiedName::create(javaClass.fullyQualifiedName)
//				val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
//				updateName(umlQualifiedName)
//			}
//		])
	}
	
}