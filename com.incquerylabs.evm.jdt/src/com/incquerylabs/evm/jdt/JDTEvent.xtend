package com.incquerylabs.evm.jdt

import org.eclipse.viatra.transformation.evm.api.event.Event
import org.eclipse.viatra.transformation.evm.api.event.EventType

class JDTEvent implements Event<JDTEventAtom> {
	EventType type
	JDTEventAtom atom

	/** 
	 * @param type
	 * @param atom
	 */
	new(EventType type, JDTEventAtom atom) {
		this.type = type
		this.atom = atom
	}


	override EventType getEventType() {
		return type
	}

	override JDTEventAtom getEventAtom() {
		return atom
	}

}
