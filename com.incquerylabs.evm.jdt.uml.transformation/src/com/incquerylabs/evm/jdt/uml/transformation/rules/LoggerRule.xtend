package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject

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