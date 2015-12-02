package com.incquerylabs.emdw.jdtuml

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.IJavaProject

class JDTEventFilter implements EventFilter<IJavaElementDelta> {
	IJavaProject project
	
	new(){
	}
	
	def setProject(IJavaProject project) {
		this.project = project
	}

	override boolean isProcessable(IJavaElementDelta eventAtom) {
		eventAtom.element.javaProject == this.project
	}

}
