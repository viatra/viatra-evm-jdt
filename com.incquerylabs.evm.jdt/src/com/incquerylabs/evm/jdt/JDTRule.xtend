package com.incquerylabs.evm.jdt

import java.util.HashSet
import java.util.Set
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import com.incquerylabs.evm.jdt.job.JDTJobFactory

abstract class JDTRule {
	protected val JDTEventSourceSpecification eventSourceSpecification
	protected val ActivationLifeCycle activationLifeCycle
	protected extension val JDTJobFactory jobFactory
	protected val Set<Job<JDTEventAtom>> jobs = new HashSet
	protected RuleSpecification<JDTEventAtom> ruleSpecification
	protected EventFilter<JDTEventAtom> filter

	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, JDTJobFactory jobFactory) {
		this.eventSourceSpecification = eventSourceSpecification
		this.activationLifeCycle = activationLifeCycle
		val filter = eventSourceSpecification.createEmptyFilter as JDTEventFilter
		filter.project = project
		this.filter = filter
		this.jobFactory = jobFactory
		initialize
	}
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project) {
		this(eventSourceSpecification, activationLifeCycle, project, new JDTJobFactory)
	}
	
	def void initialize()
	
	def EventFilter<JDTEventAtom> getFilter() {
		return filter
	}
	def RuleSpecification<JDTEventAtom> getRuleSpecification() {
		if(ruleSpecification == null) {
			ruleSpecification = new RuleSpecification(eventSourceSpecification, activationLifeCycle, jobs)
		}
		return ruleSpecification
	}
}