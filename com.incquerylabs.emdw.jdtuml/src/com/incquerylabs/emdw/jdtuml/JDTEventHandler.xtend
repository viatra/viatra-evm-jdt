package com.incquerylabs.emdw.jdtuml

import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.incquery.runtime.evm.api.event.Event
import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.incquery.runtime.evm.api.event.EventHandler
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.jdt.core.IJavaElement

class JDTEventHandler implements EventHandler<IJavaElement>{
	
	JDTEventFilter filter
	JDTEventSource source
	RuleInstance<IJavaElement> instance
	
	new(JDTEventSource source, JDTEventFilter filter, RuleInstance<IJavaElement> instance) {
		this.source=source
		this.filter=filter
		this.instance=instance 
	}
	
	override void handleEvent(Event<IJavaElement> event) {
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
	override EventSource<IJavaElement> getSource() {
		return source 
	}
	override EventFilter<? super IJavaElement> getEventFilter() {
		return filter 
	}
	override void dispose() {
		
	}
	
	private def getOrCreateActivation(IJavaElement eventAtom){
		val activations = instance.allActivations
		val activation = activations.findFirst[it.atom == eventAtom]

		if(activation == null){
			return instance.createActivation(eventAtom)
		}
		return activation
	}
}
