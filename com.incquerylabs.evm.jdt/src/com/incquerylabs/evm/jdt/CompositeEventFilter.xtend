package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventFilter

abstract class CompositeEventFilter<EventAtom> implements EventFilter<EventAtom> {
	val EventFilter<EventAtom> innerFilter
	
	new(EventFilter<EventAtom> filter) {
		this.innerFilter = filter
	}
	
	override isProcessable(EventAtom eventAtom) {
		return this.isCompositeProcessable(eventAtom) && innerFilter.isProcessable(eventAtom)
	}
	
	def boolean isCompositeProcessable(EventAtom eventAtom)
}
