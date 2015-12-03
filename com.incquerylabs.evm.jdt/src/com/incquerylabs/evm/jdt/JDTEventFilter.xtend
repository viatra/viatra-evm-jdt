package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.xtend.lib.annotations.Accessors

class JDTEventFilter implements EventFilter<IJavaElement> {
	@Accessors
	IJavaProject project
	
	new(){
	}
	
	override boolean isProcessable(IJavaElement eventAtom) {
		eventAtom.javaProject == this.project
	}

}
