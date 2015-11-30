package com.incquerylabs.emdw.jdtevents.experiment

import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta
import com.google.common.collect.Sets

class JDTEventSource implements EventSource<IJavaElementDelta> {
	JDTEventSourceSpecification spec
	JDTRealm realm
	Set<JDTEventHandler> handlers = Sets::newHashSet()

	override EventSourceSpecification<IJavaElementDelta> getSourceSpecification() {
		return spec
	}

	override EventRealm getRealm() {
		return realm
	}

	override void dispose() {
	}

	def void pushChange(IJavaElementDelta delta) {
		var JDTEvent event = new JDTEvent(JDTEventType::ELEMENT_CHANGED, delta)
		for (JDTEventHandler handler : handlers) {
			handler.handleEvent(event)
		}

	}

	def protected void addHandler(JDTEventHandler handler) {
		handlers.add(handler)
	}

	new(JDTEventSourceSpecification spec, JDTRealm realm) {
		this.spec = spec
		this.realm = realm
		realm.addSource(this)
	}

}
