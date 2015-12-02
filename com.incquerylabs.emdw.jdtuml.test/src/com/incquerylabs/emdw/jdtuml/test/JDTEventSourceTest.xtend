package com.incquerylabs.emdw.jdtuml.test

import com.incquerylabs.emdw.jdtuml.JDTEvent
import com.incquerylabs.emdw.jdtuml.JDTEventHandler
import com.incquerylabs.emdw.jdtuml.JDTEventSource
import com.incquerylabs.emdw.jdtuml.JDTEventSourceSpecification
import com.incquerylabs.emdw.jdtuml.JDTRealm
import org.eclipse.jdt.core.IJavaElementDelta
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.MockitoAnnotations

import static org.junit.Assert.*
import static org.mockito.Mockito.*

/**
 * Class under test: {@link JDTEventSource}
 */
class JDTEventSourceTest {
	@Mock JDTEventSourceSpecification eventSourceSpecification
	@Mock JDTRealm jdtRealm
	@InjectMocks JDTEventSource source
	
	@Before
	def void initMocks(){
		MockitoAnnotations.initMocks(this);
	}
	
	@Test
	def void pushChange_simpleDelta_addEvent() {
		// Arrange
		val delta = mock(IJavaElementDelta, "deltaMock")
		when(delta.affectedChildren).thenReturn(#[])
		when(delta.kind).thenReturn(IJavaElementDelta.ADDED)
		val handler = mock(JDTEventHandler, "eventHandlerMock")
		source.addHandler(handler)
		// Act
		source.pushChange(delta)
		
		// Assert
		var ArgumentCaptor<JDTEvent> eventCaptor = ArgumentCaptor.forClass(JDTEvent);
		verify(handler).handleEvent(eventCaptor.capture)
		
		assertEquals("No event created for delta", delta, eventCaptor.value.eventAtom)
	}
	
	@Test
	def void pushChange_multiLeveLDelta_addChildEvents() {
		// Arrange
		val topLevelDelta = mock(IJavaElementDelta, "topLevelDeltaMock")
		val childDelta = mock(IJavaElementDelta, "childDeltaMock")
		when(topLevelDelta.affectedChildren).thenReturn(#[childDelta])
		when(topLevelDelta.kind).thenReturn(IJavaElementDelta.ADDED)
		when(childDelta.affectedChildren).thenReturn(#[])
		when(childDelta.kind).thenReturn(IJavaElementDelta.ADDED)
		
		val handler = mock(JDTEventHandler, "eventHandlerMock")
		source.addHandler(handler)
		// Act
		source.pushChange(topLevelDelta)
		
		// Assert
		var ArgumentCaptor<JDTEvent> eventCaptor = ArgumentCaptor.forClass(JDTEvent);
		verify(handler, times(2)).handleEvent(eventCaptor.capture)
		
		val capturedEvents = eventCaptor.allValues
		assertTrue("No event created for top level delta", capturedEvents.exists[eventAtom == topLevelDelta])
		assertTrue("No event created for child delta", capturedEvents.exists[eventAtom == childDelta])
	}
}