package com.incquerylabs.evm.jdt.transactions

import com.incquerylabs.evm.jdt.JDTEvent
import com.incquerylabs.evm.jdt.JDTEventAtom
import com.incquerylabs.evm.jdt.JDTEventSource
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import org.eclipse.incquery.runtime.evm.api.event.EventSource
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElementDelta

import static extension com.incquerylabs.evm.jdt.util.JDTChangeFlagDecoder.toChangeFlags
import com.incquerylabs.evm.jdt.util.ChangeFlag
import org.apache.log4j.Logger
import org.apache.log4j.Level

class JDTTransactionalEventSource extends JDTEventSource implements EventSource<JDTEventAtom> {
	extension val Logger logger = Logger.getLogger(this.class)
	
	new(JDTEventSourceSpecification spec, JDTRealm realm) {
		super(spec, realm)
		logger.level = Level.DEBUG
	}
	
	override void createEvent(IJavaElementDelta delta) {
		// Transactional events are made only for CompilationUnits
		if((delta.element instanceof ICompilationUnit)){
			val eventAtom = new JDTEventAtom(delta)
			
			// Create events with the correct event types, and send them to the handlers
			val eventTypes = delta.transactionalEventTypes
			eventTypes.forEach[ eventTpye |
				val event = new JDTEvent(eventTpye, eventAtom)
				debug('''Created event with type «eventTpye» for «eventAtom.delta»''')
				handlers.forEach[handleEvent(event)]
				Thread.sleep(200)
			]
		} else {
			super.createEvent(delta)
		}
		
		// Always process child-deltas
		delta.affectedChildren.forEach[affectedChildren |
			createEvent(affectedChildren)
		]
	}
	
	private def getTransactionalEventTypes(IJavaElementDelta delta) {
		val result = newArrayList()
		val flags = delta.flags.toChangeFlags
		// If something is removed, send delete event
		if(delta.kind.bitwiseAnd(IJavaElementDelta::REMOVED) != 0) {
			result.add(JDTTransactionalEventType::DELETE)
		// If something is added, send modify and commit event
		} else if( delta.kind.bitwiseAnd(IJavaElementDelta::ADDED) != 0) {
			result.add(JDTTransactionalEventType::CREATE)
			result.add(JDTTransactionalEventType::COMMIT)
		// If something is modified
		} else {
			// If its content or its children are changed, send modify event
			if( flags.exists[ flag |
				flag == ChangeFlag::CONTENT ||
				flag == ChangeFlag::CHILDREN
			]) {
				result.add(JDTTransactionalEventType::MODIFY)
			}
			// If the primary resource is changed (aka saved) send an additional commit event
			if( flags.exists[ flag | 
				flag == ChangeFlag::PRIMARY_RESOURCE
			]) {
				result.add(JDTTransactionalEventType::COMMIT)
			}
		}
		return result
	}
}
