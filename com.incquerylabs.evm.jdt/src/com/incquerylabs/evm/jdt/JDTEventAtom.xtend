package com.incquerylabs.evm.jdt

import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.xtend.lib.annotations.Accessors

class JDTEventAtom {
	@Accessors
	val IJavaElement element
	@Accessors
	IJavaElementDelta delta
	
	new(IJavaElementDelta delta) {
		this.delta = delta
		this.element = delta.element
	}
	
	override equals(Object obj) {
		if(obj instanceof JDTEventAtom) {
			return element == obj.element
		}
		return false
	}
	
}
