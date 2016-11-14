package com.incquerylabs.evm.jdt.uml.transformation.rules

import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.viatra.integration.evm.jdt.JDTActivationState
import org.eclipse.viatra.integration.evm.jdt.JDTEventSourceSpecification
import org.eclipse.viatra.integration.evm.jdt.JDTRule
import org.eclipse.viatra.transformation.evm.api.ActivationLifeCycle

class LoggerRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project) {
		super(eventSourceSpecification, activationLifeCycle, project)
		logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(createJob(JDTActivationState.APPEARED)[activation, context |
			debug('''Element appeared: «activation.atom.element»''')
		])
		jobs.add(createJob(JDTActivationState.DISAPPEARED)[activation, context |
			debug('''Element disappeared: «activation.atom.element»''')
		])
		jobs.add(createJob(JDTActivationState.UPDATED)[activation, context |
			debug('''Element is updated: «activation.atom.element»''')
		])
	}
	
}