package com.incquerylabs.evm.jdt

import org.eclipse.viatra.transformation.evm.api.RuleInstance
import org.eclipse.viatra.transformation.evm.api.event.Event
import org.eclipse.viatra.transformation.evm.api.event.EventFilter
import org.eclipse.viatra.transformation.evm.api.event.EventHandler
import org.eclipse.viatra.transformation.evm.api.event.EventSource
import org.eclipse.viatra.transformation.evm.api.event.EventType

class JDTEventHandler implements EventHandler<JDTEventAtom>{
	
	EventFilter<? super JDTEventAtom> filter
	JDTEventSource source
	RuleInstance<JDTEventAtom> instance
	
	new(JDTEventSource source, EventFilter<? super JDTEventAtom> filter, RuleInstance<JDTEventAtom> instance) {
		this.source=source
		this.filter=filter
		this.instance=instance 
	}
	
	override void handleEvent(Event<JDTEventAtom> event) {
		val type=event.getEventType() as EventType
		val eventAtom=event.getEventAtom()
		if(filter.isProcessable(eventAtom)){
			val activation = getOrCreateActivation(eventAtom)
			instance.activationStateTransition(activation, type)
		}
	}
	override EventSource<JDTEventAtom> getSource() {
		return source 
	}
	override EventFilter<? super JDTEventAtom> getEventFilter() {
		return filter
	}
	override void dispose() {
		// remove handler from source
		source.removeHandler(this)
	}
	
	private def getOrCreateActivation(JDTEventAtom eventAtom){
		val activations = instance.allActivations
		val activation = activations.findFirst[it.atom == eventAtom]

		if(activation == null){
			return instance.createActivation(eventAtom)
		} else {
			activation.atom.delta = eventAtom.delta
		}
		return activation
	}
}
