package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.incquery.runtime.evm.api.event.AbstractRuleInstanceBuilder
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElement

class JDTEventSourceSpecification implements EventSourceSpecification<IJavaElement> {
	override EventFilter<IJavaElement> createEmptyFilter() {
		return new JDTEventFilter()
	}

	override AbstractRuleInstanceBuilder<IJavaElement> getRuleInstanceBuilder(EventRealm realm) {
		return ( [ RuleInstance<IJavaElement> ruleInstance, EventFilter<? super IJavaElement> filter |
			var JDTEventSource source = new JDTEventSource(JDTEventSourceSpecification.this, realm as JDTRealm)
			var JDTEventHandler handler = new JDTEventHandler(source, filter as JDTEventFilter, ruleInstance)
			source.addHandler(handler)
		] as AbstractRuleInstanceBuilder<IJavaElement>)
	}

}
