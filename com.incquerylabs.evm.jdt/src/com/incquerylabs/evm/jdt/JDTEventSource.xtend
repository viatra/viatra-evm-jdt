package com.incquerylabs.evm.jdt

import com.google.common.collect.Sets
import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta

import static extension com.incquerylabs.evm.jdt.util.JDTEventTypeDecoder.toEventType
import org.eclipse.incquery.runtime.evm.api.event.EventHandler
import org.eclipse.jdt.core.IJavaElement
import com.incquerylabs.evm.jdt.transactions.JDTTransactionalEventType

class JDTEventSource implements EventSource<JDTEventAtom> {
	JDTEventSourceSpecification spec
	JDTRealm realm
	Set<EventHandler<JDTEventAtom>> handlers = Sets::newHashSet()
	
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
		handlers.forEach[
			handleEvent(event)
		]
		delta.affectedChildren.forEach[affectedChildren |
			createEvent(affectedChildren)
		]
	}

	def void createReferenceRefreshEvent(IJavaElement javaElement) {
		val eventAtom = new JDTEventAtom(javaElement)
		val JDTEvent event = new JDTEvent(JDTTransactionalEventType::UPDATE_DEPENDENCY, eventAtom)
		handlers.forEach[
			handleEvent(event)
		]
	}

	def void addHandler(EventHandler<JDTEventAtom> handler) {
		handlers.add(handler)
	}
	
	def getHandlers() {
		return handlers
	}
}
