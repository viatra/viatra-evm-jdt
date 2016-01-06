package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.xtend.lib.annotations.Accessors

abstract class CompositeEventFilter<EventAtom> implements EventFilter<EventAtom> {
	@Accessors
	val EventFilter<EventAtom> innerFilter
	
	new(EventFilter<EventAtom> filter) {
		this.innerFilter = filter
	}
	
	override isProcessable(EventAtom eventAtom) {
		return this.isCompositeProcessable(eventAtom) && innerFilter.isProcessable(eventAtom)
	}
	
	def boolean isCompositeProcessable(EventAtom eventAtom)
}
