package com.incquerylabs.evm.jdt.transactions;

import org.eclipse.incquery.runtime.evm.api.event.ActivationState;

public enum JDTTransactionalActivationState implements ActivationState {
	INACTIVE,
	MODIFIED,
	COMMITTED,
	DELETED,
	FIRED;

	@Override
	public boolean isInactive() {
		return this.equals(INACTIVE);
	}
}
