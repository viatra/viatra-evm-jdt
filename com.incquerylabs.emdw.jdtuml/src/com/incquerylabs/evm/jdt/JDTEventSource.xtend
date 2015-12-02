package com.incquerylabs.emdw.jdtuml

import com.google.common.collect.Sets
import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta

import static extension com.incquerylabs.emdw.jdtuml.util.JDTEventTypeDecoder.toEventType
import org.eclipse.jdt.core.IJavaElement

class JDTEventSource implements EventSource<IJavaElement> {
	JDTEventSourceSpecification spec
	JDTRealm realm
	Set<JDTEventHandler> handlers = Sets::newHashSet()
	
	new(JDTEventSourceSpecification spec, JDTRealm realm) {
		this.spec = spec
		this.realm = realm
		realm.addSource(this)
	}

	override EventSourceSpecification<IJavaElement> getSourceSpecification() {
		return spec
	}

	override EventRealm getRealm() {
		return realm
	}

	override void dispose() {
	}

	def void pushChange(IJavaElementDelta delta) {
		val javaElement = delta.element
		val JDTEvent event = new JDTEvent(delta.kind.toEventType, javaElement)
		handlers.forEach[handleEvent(event)]
		delta.affectedChildren.forEach[affectedChildren |
			pushChange(affectedChildren)
		]
	}

	def void addHandler(JDTEventHandler handler) {
		handlers.add(handler)
	}
}
