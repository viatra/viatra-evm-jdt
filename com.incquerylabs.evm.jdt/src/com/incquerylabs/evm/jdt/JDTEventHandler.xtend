package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.incquery.runtime.evm.api.event.Event
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.incquery.runtime.evm.api.event.EventHandler
import org.eclipse.incquery.runtime.evm.api.event.EventSource

class JDTEventHandler implements EventHandler<JDTEventAtom>{
	
	JDTEventFilter filter
	JDTEventSource source
	RuleInstance<JDTEventAtom> instance
	
	new(JDTEventSource source, JDTEventFilter filter, RuleInstance<JDTEventAtom> instance) {
		this.source=source
		this.filter=filter
		this.instance=instance 
	}
	
	override void handleEvent(Event<JDTEventAtom> event) {
		val type=event.getEventType() as JDTEventType 
		val eventAtom=event.getEventAtom() 
		val activation = getOrCreateActivation(eventAtom)
		
		switch (type) {
			case APPEARED:{
				instance.activationStateTransition(activation, type)
			}
			case DISAPPEARED:{
				instance.activationStateTransition(activation, type)
			}
			case UPDATED:{
				instance.activationStateTransition(activation, type)
			}
			default :{
				System.err.println("Something bad happened")
			}
		}
	}
	override EventSource<JDTEventAtom> getSource() {
		return source 
	}
	override EventFilter<? super JDTEventAtom> getEventFilter() {
		return filter 
	}
	override void dispose() {
		
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
