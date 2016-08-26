package com.incquerylabs.evm.jdt.transactions;

import org.eclipse.viatra.transformation.evm.api.event.EventType;

public enum JDTTransactionalEventType implements EventType {
	CREATE,
	DELETE,
	MODIFY,
	COMMIT,
	UPDATE_DEPENDENCY
}
