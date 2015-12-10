package com.incquerylabs.evm.jdt.test

import com.incquerylabs.evm.jdt.JDTEvent
import com.incquerylabs.evm.jdt.JDTEventHandler
import com.incquerylabs.evm.jdt.JDTEventSource
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import org.eclipse.jdt.core.IJavaElementDelta
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.MockitoAnnotations

import static org.junit.Assert.*
import static org.mockito.Mockito.*
import org.eclipse.jdt.core.IJavaElement

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
		val element = mock(IJavaElement, "javaElementMock")
		when(delta.affectedChildren).thenReturn(#[])
		when(delta.kind).thenReturn(IJavaElementDelta.ADDED)
		when(delta.element).thenReturn(element)
		val handler = mock(JDTEventHandler, "eventHandlerMock")
		source.addHandler(handler)
		// Act
		source.createEvent(delta)
		
		// Assert
		var ArgumentCaptor<JDTEvent> eventCaptor = ArgumentCaptor.forClass(JDTEvent);
		verify(handler).handleEvent(eventCaptor.capture)
		
		assertEquals("No event created for delta", element, eventCaptor.value.eventAtom)
	}
	
	@Test
	def void pushChange_multiLeveLDelta_addChildEvents() {
		// Arrange
		val topLevelDelta = mock(IJavaElementDelta, "topLevelDeltaMock")
		val topLevelElement = mock(IJavaElement, "topLevelJavaElementMock")
		val childDelta = mock(IJavaElementDelta, "childDeltaMock")
		val childElement = mock(IJavaElement, "childJavaElementMock")
		when(topLevelDelta.affectedChildren).thenReturn(#[childDelta])
		when(topLevelDelta.kind).thenReturn(IJavaElementDelta.ADDED)
		when(topLevelDelta.element).thenReturn(topLevelElement)
		
		when(childDelta.affectedChildren).thenReturn(#[])
		when(childDelta.kind).thenReturn(IJavaElementDelta.ADDED)
		when(childDelta.element).thenReturn(childElement)
		
		val handler = mock(JDTEventHandler, "eventHandlerMock")
		source.addHandler(handler)
		// Act
		source.createEvent(topLevelDelta)
		
		// Assert
		var ArgumentCaptor<JDTEvent> eventCaptor = ArgumentCaptor.forClass(JDTEvent);
		verify(handler, times(2)).handleEvent(eventCaptor.capture)
		
		val capturedEvents = eventCaptor.allValues
		assertTrue("No event created for top level delta", capturedEvents.exists[eventAtom == topLevelElement])
		assertTrue("No event created for child delta", capturedEvents.exists[eventAtom == childElement])
	}
}