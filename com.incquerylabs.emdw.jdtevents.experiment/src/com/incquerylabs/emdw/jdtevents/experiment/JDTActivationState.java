package com.incquerylabs.emdw.jdtevents.experiment;

import org.eclipse.incquery.runtime.evm.api.event.ActivationState;

public enum JDTActivationState implements ActivationState {
	ACTIVE,
	INACTIVE;

	@Override
	public boolean isInactive() {
		return this.equals(INACTIVE);
	}

}
