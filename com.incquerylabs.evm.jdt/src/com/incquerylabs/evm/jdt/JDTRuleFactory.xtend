package com.incquerylabs.evm.jdt

import java.util.Set
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.jdt.core.IJavaElement

class JDTRuleFactory {
	val JDTEventSourceSpecification sourceSpecification
	val ActivationLifeCycle activationLifeCycle
	
	new(JDTEventSourceSpecification sourceSpecification, ActivationLifeCycle activationLifeCycle) {
		this.sourceSpecification = sourceSpecification
		this.activationLifeCycle = activationLifeCycle
	}
	
	def JDTRule createRule(Set<Job<IJavaElement>> jobs, JDTEventFilter filter){
		val ruleSpecification = new RuleSpecification(sourceSpecification, activationLifeCycle, jobs)
		return new JDTRule(ruleSpecification, filter)
	}
}
