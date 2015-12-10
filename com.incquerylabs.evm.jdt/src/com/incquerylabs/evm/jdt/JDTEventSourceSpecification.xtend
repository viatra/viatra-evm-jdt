package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.incquery.runtime.evm.api.event.AbstractRuleInstanceBuilder
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification

class JDTEventSourceSpecification implements EventSourceSpecification<JDTEventAtom> {
	override EventFilter<JDTEventAtom> createEmptyFilter() {
		return new JDTEventFilter()
	}

	override AbstractRuleInstanceBuilder<JDTEventAtom> getRuleInstanceBuilder(EventRealm realm) {
		return ( [ RuleInstance<JDTEventAtom> ruleInstance, EventFilter<? super JDTEventAtom> filter |
			var JDTEventSource source = new JDTEventSource(JDTEventSourceSpecification.this, realm as JDTRealm)
			var JDTEventHandler handler = new JDTEventHandler(source, filter, ruleInstance)
			source.addHandler(handler)
		] as AbstractRuleInstanceBuilder<JDTEventAtom>)
	}

}
