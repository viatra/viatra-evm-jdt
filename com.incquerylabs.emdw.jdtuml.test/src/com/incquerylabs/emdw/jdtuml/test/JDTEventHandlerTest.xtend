package com.incquerylabs.emdw.jdtuml.test

import com.incquerylabs.emdw.jdtuml.JDTEvent
import com.incquerylabs.emdw.jdtuml.JDTEventHandler
import com.incquerylabs.emdw.jdtuml.JDTEventType
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.RuleInstance
import org.eclipse.jdt.core.IJavaElement
import org.junit.Before
import org.junit.Test
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.MockitoAnnotations

import static org.mockito.Mockito.*

class JDTEventHandlerTest {
	@Mock(name = "ruleInstanceMock") 
	private RuleInstance<IJavaElement> ruleInstance
	@InjectMocks 
	private JDTEventHandler eventHandler
	
	
	@Before
	def void initMocks(){
		MockitoAnnotations.initMocks(this);
	}
	
	@Test
	def void handleEvent_appearedEvent_lifecycleTransitionCalled() {
		// Arrange
		val eventType = JDTEventType.APPEARED
		val eventAtom = mock(IJavaElement, "eventAtomMock")
		val event = mock(JDTEvent, "eventMock")
		when(event.eventType).thenReturn(eventType)
		when(event.eventAtom).thenReturn(eventAtom)
		
		val activation = mock(Activation, "activationMock")
		when(ruleInstance.createActivation(eventAtom)).thenReturn(activation)
		
		// Act
		eventHandler.handleEvent(event)
		
		// Assert
		// New activation is created
		verify(ruleInstance).createActivation(eventAtom)
		// Life cycle transition is called on the new activation
		verify(ruleInstance).activationStateTransition(activation, eventType)
	}
	
	@Test
	def void handleEvent_withExistingActivation_lifecycleTransitionCalled() {
		// Arrange
		// The new event with a type and an atom
		val eventType = JDTEventType.DISAPPEARED
		val eventAtom = mock(IJavaElement, "eventAtomMock")
		val event = mock(JDTEvent, "eventMock")
		when(event.eventType).thenReturn(eventType)
		when(event.eventAtom).thenReturn(eventAtom)
		
		// Exisiting activation with same event atom
		val Activation<IJavaElement> activation = mock(Activation, "activationMock")
		when(activation.atom).thenReturn(eventAtom)
		when(ruleInstance.allActivations).thenReturn(#[activation])
		
		// Act
		eventHandler.handleEvent(event)
		
		// Assert
		// New activation is NOT created
		verify(ruleInstance, never).createActivation(any(IJavaElement))
		// Life cycle transition is called on the new activation
		verify(ruleInstance).activationStateTransition(activation, eventType)
	}
}
