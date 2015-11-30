package com.incquerylabs.emdw.jdtevents.experiment

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaElementDelta

class JDTEventFilter implements EventFilter<IJavaElementDelta> {
	// private String regexp;
	new() {
	}

	// public JDTEventFilter(String regexp) {
	// this.regexp = regexp;
	// }
	override boolean isProcessable(IJavaElementDelta eventAtom) {
		return true
	}

}
