package com.incquerylabs.evm.jdt

import com.google.common.collect.Sets
import java.util.Set
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.event.EventRealm
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.IJavaElementDelta

class JDTRealm implements EventRealm {
	Set<JDTEventSource> sources = Sets.newHashSet()
	extension val Logger logger = Logger.getLogger(this.class)

	/** 
	 */
	new() {
		logger.level = Level.DEBUG
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			val delta = event.delta
			notifySources(delta)
		] as IElementChangedListener))
	}
	
	private def notifySources(IJavaElementDelta delta) {
		sources.forEach[
			createEvent(delta)
		]
	}
	
	def protected void addSource(JDTEventSource source) {
		sources.add(source)
	}

}
