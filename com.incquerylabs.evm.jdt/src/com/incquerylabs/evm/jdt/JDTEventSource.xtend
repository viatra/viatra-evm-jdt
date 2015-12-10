package com.incquerylabs.evm.jdt

import com.google.common.collect.Sets
import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta

import static extension com.incquerylabs.evm.jdt.util.JDTEventTypeDecoder.toEventType

class JDTEventSource implements EventSource<JDTEventAtom> {
	JDTEventSourceSpecification spec
	JDTRealm realm
	Set<JDTEventHandler> handlers = Sets::newHashSet()
	
	new(JDTEventSourceSpecification spec, JDTRealm realm) {
		this.spec = spec
		this.realm = realm
		realm.addSource(this)
	}

	override EventSourceSpecification<JDTEventAtom> getSourceSpecification() {
		return spec
	}

	override EventRealm getRealm() {
		return realm
	}

	override void dispose() {
	}

	def void createEvent(IJavaElementDelta delta) {
		val eventAtom = new JDTEventAtom(delta)
		val JDTEvent event = new JDTEvent(delta.kind.toEventType, eventAtom)
		handlers.forEach[handleEvent(event)]
		delta.affectedChildren.forEach[affectedChildren |
			createEvent(affectedChildren)
		]
	}

	def void addHandler(JDTEventHandler handler) {
		handlers.add(handler)
	}
}
