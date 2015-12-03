package com.incquerylabs.evm.jdt

import java.util.Set
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IJavaProject
import java.util.HashSet

abstract class JDTRule {
	protected val JDTEventSourceSpecification eventSourceSpecification
	protected val ActivationLifeCycle activationLifeCycle
	protected val Set<Job<IJavaElement>> jobs = new HashSet
	protected RuleSpecification<IJavaElement> ruleSpecification
	protected JDTEventFilter filter
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project) {
		this.eventSourceSpecification = eventSourceSpecification
		this.activationLifeCycle = activationLifeCycle
		this.filter = eventSourceSpecification.createEmptyFilter as JDTEventFilter
		this.filter.project = project
		initialize
	}
	
	def void initialize()
	
	def JDTEventFilter getFilter() {
		return filter
	}
	def RuleSpecification<IJavaElement> getRuleSpecification() {
		if(ruleSpecification == null) {
			ruleSpecification = new RuleSpecification(eventSourceSpecification, activationLifeCycle, jobs)
		}
		return ruleSpecification
	}
}