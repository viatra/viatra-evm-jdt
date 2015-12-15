package com.incquerylabs.evm.jdt.transactions

import com.google.common.collect.Sets
import com.incquerylabs.evm.jdt.JDTEvent
import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventHandler
import com.incquerylabs.evm.jdt.JDTEventSource
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.ICompilationUnit

class JDTTransactionalEventSource extends JDTEventSource implements EventSource<JDTEventAtom> {
	JDTEventSourceSpecification spec
	JDTRealm realm
	Set<JDTEventHandler> handlers = Sets::newHashSet()
	
	new(JDTEventSourceSpecification spec, JDTRealm realm) {
		super(spec, realm)
	}
	
	override EventSourceSpecification<JDTEventAtom> getSourceSpecification() {
		return spec
	}

	override EventRealm getRealm() {
		return realm
	}

	override void dispose() {
	}

	override void createEvent(IJavaElementDelta delta) {
		val eventAtom = new JDTEventAtom(delta)
		
		val eventType = delta.transactionalEventType
		val JDTEvent event = new JDTEvent(eventType, eventAtom)
		sendToHandlers(event)
		
		if(eventType == JDTTransactionalEventType::CREATE &&
			eventAtom.element instanceof ICompilationUnit
		) {
			val commitEvent = new JDTEvent(JDTTransactionalEventType::COMMIT, eventAtom)
			sendToHandlers(commitEvent)
		}
		
		delta.affectedChildren.forEach[affectedChildren |
			createEvent(affectedChildren)
		]
	}

	override void addHandler(JDTEventHandler handler) {
		handlers.add(handler)
	}
	
	private def sendToHandlers(JDTEvent event) {
		handlers.forEach[handleEvent(event)]
	}
	
	private def JDTTransactionalEventType getTransactionalEventType(IJavaElementDelta delta) {
		if(delta.kind.bitwiseAnd(IJavaElementDelta::CHANGED) != 0) {
			if(delta.flags.bitwiseAnd(IJavaElementDelta::F_PRIMARY_RESOURCE) != 0) {
				return JDTTransactionalEventType::COMMIT
			}
			return JDTTransactionalEventType::MODIFY
		}
		if(delta.kind.bitwiseAnd(IJavaElementDelta::REMOVED) != 0
		) {
			return JDTTransactionalEventType::DELETE
		}
		if(delta.kind.bitwiseAnd(IJavaElementDelta::ADDED) != 0
		) {
			return JDTTransactionalEventType::CREATE
		}
	}
}
