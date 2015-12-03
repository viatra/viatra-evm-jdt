package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject

class ClassRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project) {
		super(eventSourceSpecification, activationLifeCycle, project)
	}
	
	override initialize() {
		jobs.add(JDTJobFactory.createJob(JDTActivationState.APPEARED)[activation, context |
				debug('''APPEARED: «activation.atom.elementName»''')
		])
		jobs.add(JDTJobFactory.createJob(JDTActivationState.DISAPPEARED)[activation, context |
				debug('''DISAPPEARED: «activation.atom.elementName»''')
		])
		jobs.add(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
				debug('''UPDATED: «activation.atom.elementName»''')
		])
	}
	
}