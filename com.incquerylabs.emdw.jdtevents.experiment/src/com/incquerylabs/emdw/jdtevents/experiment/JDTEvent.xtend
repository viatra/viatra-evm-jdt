package com.incquerylabs.emdw.jdtevents.experiment

import org.eclipse.incquery.runtime.evm.api.event.Event
import org.eclipse.incquery.runtime.evm.api.event.EventType
import org.eclipse.jdt.core.IJavaElementDelta

class JDTEvent implements Event<IJavaElementDelta> {
	JDTEventType type

	/** 
	 * @param type
	 * @param atom
	 */
	new(JDTEventType type, IJavaElementDelta atom) {
		this.type = type
		this.atom = atom
	}

	IJavaElementDelta atom

	override EventType getEventType() {
		return type
	}

	override IJavaElementDelta getEventAtom() {
		return atom
	}

}
