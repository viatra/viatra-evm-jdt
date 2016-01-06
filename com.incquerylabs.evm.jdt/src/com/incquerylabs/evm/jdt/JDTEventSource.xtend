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
import org.eclipse.jdt.core.JavaCore
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragmentRoot

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
		// send events to handler for existing activations
		val filter = handler.eventFilter
		val project = getJavaProject(filter)
		val pckgfr = project.packageFragments.filter[kind == IPackageFragmentRoot.K_SOURCE].toList
		
		pckgfr.forEach[
			handler.sendExistingEvents(it)
			compilationUnits.forEach[
				handler.sendExistingEvents(it)
			]
		]
		
		handlers.add(handler)
	}
	
	def sendExistingEvents(EventHandler<JDTEventAtom> handler, IJavaElement element) {
		val eventAtom = new JDTEventAtom(element)
		val JDTEvent createEvent = new JDTEvent(JDTTransactionalEventType::CREATE, eventAtom)
		handler.handleEvent(createEvent)
		val JDTEvent commitEvent = new JDTEvent(JDTTransactionalEventType::COMMIT, eventAtom)
		handler.handleEvent(commitEvent)
	}
	
	def IJavaProject getJavaProject(EventFilter<? super JDTEventAtom> filter) {
		if(filter instanceof JDTEventFilter){
			return filter.project
		} else if(filter instanceof CompositeEventFilter){
			return getJavaProject(filter.innerFilter)
		}
		return null
	}
	
	def getHandlers() {
		return handlers
	}
}
