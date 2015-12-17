package com.incquerylabs.evm.jdt.transactions

import org.eclipse.incquery.runtime.evm.api.event.EventType.RuleEngineEventType
import org.eclipse.incquery.runtime.evm.specific.lifecycle.UnmodifiableActivationLifeCycle

class JDTTransactionalLifecycle extends UnmodifiableActivationLifeCycle {
	
	new() {
		super(JDTTransactionalActivationState.INACTIVE);

		internalAddStateTransition(JDTTransactionalActivationState.INACTIVE, JDTTransactionalEventType.CREATE, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.MODIFIED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.MODIFIED, JDTTransactionalEventType.COMMIT, JDTTransactionalActivationState.COMMITTED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, JDTTransactionalEventType.MODIFY, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.COMMITTED, RuleEngineEventType.FIRE, JDTTransactionalActivationState.FIRED);
		internalAddStateTransition(JDTTransactionalActivationState.FIRED, JDTTransactionalEventType.MODIFY, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.FIRED, JDTTransactionalEventType.DELETE, JDTTransactionalActivationState.DELETED);
		internalAddStateTransition(JDTTransactionalActivationState.DELETED, JDTTransactionalEventType.CREATE, JDTTransactionalActivationState.MODIFIED);
		internalAddStateTransition(JDTTransactionalActivationState.DELETED, RuleEngineEventType.FIRE, JDTTransactionalActivationState.INACTIVE);
	}
	
}