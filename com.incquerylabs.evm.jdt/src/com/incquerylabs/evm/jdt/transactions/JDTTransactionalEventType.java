package com.incquerylabs.evm.jdt.transactions;

import org.eclipse.incquery.runtime.evm.api.event.EventType;

public enum JDTTransactionalEventType implements EventType {
	CREATE,
	DELETE,
	MODIFY,
	COMMIT
}
