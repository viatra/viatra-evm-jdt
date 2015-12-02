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
		var JDTEventType type=event.getEventType() as JDTEventType 
		var IJavaElement eventAtom=event.getEventAtom() 
		
		switch (type) {
			case APPEARED:{
				var activation=instance.createActivation(eventAtom)
				instance.activationStateTransition(activation, type)
			}
			case DISAPPEARED:{
				var activation=instance.createActivation(eventAtom) 
				instance.activationStateTransition(activation, type)
			}
			case UPDATED:{
				var activation=instance.createActivation(eventAtom) 
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
}
