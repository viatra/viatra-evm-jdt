package com.incquerylabs.evm.jdt

import java.util.Set
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.jdt.core.IJavaElementDelta
import com.google.common.collect.Sets

class JDTRealm implements EventRealm {
	Set<JDTEventSource> sources = Sets.newHashSet()

	/** 
	 */
	new() {
	}

	def void pushChange(IJavaElementDelta delta) {
		for (JDTEventSource source : sources) {
			source.pushChange(delta)
		}

	}

	def protected void addSource(JDTEventSource source) {
		sources.add(source)
	}

}
