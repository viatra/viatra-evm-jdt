package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.Event
import org.eclipse.incquery.runtime.evm.api.event.EventType
import org.eclipse.jdt.core.IJavaElement

class JDTEvent implements Event<IJavaElement> {
	JDTEventType type
	IJavaElement atom

	/** 
	 * @param type
	 * @param atom
	 */
	new(JDTEventType type, IJavaElement atom) {
		this.type = type
		this.atom = atom
	}


	override EventType getEventType() {
		return type
	}

	override IJavaElement getEventAtom() {
		return atom
	}

}
