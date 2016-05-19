package com.incquerylabs.evm.jdt.transactions

import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventHandler
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import org.eclipse.viatra.transformation.evm.api.RuleInstance
import org.eclipse.viatra.transformation.evm.api.event.AbstractRuleInstanceBuilder
import org.eclipse.viatra.transformation.evm.api.event.EventFilter
import org.eclipse.viatra.transformation.evm.api.event.EventRealm

class JDTTransactionalEventSourceSpecification extends JDTEventSourceSpecification {
	override getRuleInstanceBuilder(EventRealm realm) {
		return ( [ RuleInstance<JDTEventAtom> ruleInstance, EventFilter<? super JDTEventAtom> filter |
			val source = new JDTTransactionalEventSource(JDTTransactionalEventSourceSpecification.this, realm as JDTRealm)
			val handler = new JDTEventHandler(source, filter, ruleInstance)
			source.addHandler(handler)
			ruleInstance.handler = handler
		] as AbstractRuleInstanceBuilder<JDTEventAtom>)
	}
}
