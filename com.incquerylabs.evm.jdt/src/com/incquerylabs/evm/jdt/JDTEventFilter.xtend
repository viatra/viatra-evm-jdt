package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaProject

class JDTEventFilter implements EventFilter<IJavaElement> {
	IJavaProject project
	
	new(){
	}
	
	def setProject(IJavaProject project) {
		this.project = project
	}

	override boolean isProcessable(IJavaElement eventAtom) {
		eventAtom.javaProject == this.project
	}

}
