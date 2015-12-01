package com.incquerylabs.emdw.jdtuml.util

import com.incquerylabs.emdw.jdtuml.JDTEventType
import org.eclipse.jdt.core.IJavaElementDelta

class JDTEventTypeDecoder {
	public static def toEventType(int value) {
		switch value {
			case IJavaElementDelta.ADDED:
				return JDTEventType.APPEARED
			case IJavaElementDelta.REMOVED:
				return JDTEventType.DISAPPEARED
			case IJavaElementDelta.CHANGED:
				return JDTEventType.UPDATED
			default :
				throw new IllegalArgumentException("Event type value is invalid.")
				
		}
	}
}
