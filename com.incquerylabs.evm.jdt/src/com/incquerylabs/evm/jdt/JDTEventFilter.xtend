package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.event.EventFilter
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.xtend.lib.annotations.Accessors

class JDTEventFilter implements EventFilter<JDTEventAtom> {
	@Accessors
	IJavaProject project
	
	new(){
	}
	
	override boolean isProcessable(JDTEventAtom eventAtom) {
		eventAtom.element.javaProject == this.project
	}

}
