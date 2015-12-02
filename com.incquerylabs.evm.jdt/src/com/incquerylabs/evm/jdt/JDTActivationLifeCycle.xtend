package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventType.RuleEngineEventType
import org.eclipse.incquery.runtime.evm.specific.lifecycle.UnmodifiableActivationLifeCycle

class JDTActivationLifeCycle extends UnmodifiableActivationLifeCycle {
	
	new() {
		super(JDTActivationState.INACTIVE);

		internalAddStateTransition(JDTActivationState.INACTIVE, JDTEventType.APPEARED, JDTActivationState.APPEARED);
		internalAddStateTransition(JDTActivationState.APPEARED, JDTEventType.DISAPPEARED, JDTActivationState.INACTIVE);
		internalAddStateTransition(JDTActivationState.APPEARED, RuleEngineEventType.FIRE, JDTActivationState.FIRED);
		internalAddStateTransition(JDTActivationState.FIRED, JDTEventType.UPDATED, JDTActivationState.UPDATED);
		internalAddStateTransition(JDTActivationState.FIRED, JDTEventType.DISAPPEARED, JDTActivationState.DISAPPEARED);
		internalAddStateTransition(JDTActivationState.UPDATED, RuleEngineEventType.FIRE, JDTActivationState.FIRED);
		internalAddStateTransition(JDTActivationState.UPDATED, JDTEventType.DISAPPEARED, JDTActivationState.DISAPPEARED);
		internalAddStateTransition(JDTActivationState.DISAPPEARED, JDTEventType.APPEARED, JDTActivationState.UPDATED);
		internalAddStateTransition(JDTActivationState.DISAPPEARED, RuleEngineEventType.FIRE, JDTActivationState.INACTIVE);
	}
}