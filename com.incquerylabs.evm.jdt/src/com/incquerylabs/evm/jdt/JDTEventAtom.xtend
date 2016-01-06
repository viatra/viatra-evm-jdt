package com.incquerylabs.evm.jdt

import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional

class JDTEventAtom {
	@Accessors
	val IJavaElement element
	@Accessors
	Optional<? extends IJavaElementDelta> delta
	
	new(IJavaElementDelta delta) {
		this.delta = Optional::of(delta)
		this.element = delta.element
	}
	
	new(IJavaElement javaElement) {
		this.delta = Optional::empty
		this.element = javaElement
	}
	
	override equals(Object obj) {
		if(obj instanceof JDTEventAtom) {
			return element == obj.element
		}
		return false
	}
	
	override toString() {
		element.toString() + " : " + delta.toString()
	}
	
}
