package com.incquerylabs.emdw.jdtuml

import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.incquery.runtime.evm.api.event.AbstractRuleInstanceBuilder
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta

class JDTEventSourceSpecification implements EventSourceSpecification<IJavaElementDelta> {
	override EventFilter<IJavaElementDelta> createEmptyFilter() {
		return new JDTEventFilter()
	}

	override AbstractRuleInstanceBuilder<IJavaElementDelta> getRuleInstanceBuilder(EventRealm realm) {
		return ( [ RuleInstance<IJavaElementDelta> ruleInstance, EventFilter<? super IJavaElementDelta> filter |
			var JDTEventSource source = new JDTEventSource(JDTEventSourceSpecification.this, realm as JDTRealm)
			var JDTEventHandler handler = new JDTEventHandler(source, filter as JDTEventFilter, ruleInstance)
			source.addHandler(handler)
		] as AbstractRuleInstanceBuilder<IJavaElementDelta>)
	}

}
