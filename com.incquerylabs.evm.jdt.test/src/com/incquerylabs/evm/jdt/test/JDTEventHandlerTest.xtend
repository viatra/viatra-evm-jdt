package com.incquerylabs.evm.jdt.test

import org.eclipse.jdt.core.IJavaElement
import org.eclipse.viatra.integration.evm.jdt.JDTEvent
import org.eclipse.viatra.integration.evm.jdt.JDTEventAtom
import org.eclipse.viatra.integration.evm.jdt.JDTEventHandler
import org.eclipse.viatra.integration.evm.jdt.JDTEventType
import org.eclipse.viatra.transformation.evm.api.Activation
import org.eclipse.viatra.transformation.evm.api.RuleInstance
import org.junit.Before
import org.junit.Test
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.MockitoAnnotations

import static org.mockito.Matchers.*
import static org.mockito.Mockito.*

class JDTEventHandlerTest {
	@Mock(name = "ruleInstanceMock") 
	private RuleInstance<JDTEventAtom> ruleInstance
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
		val javaElement = mock(IJavaElement, "javaElementMock")
		val eventAtom = mock(JDTEventAtom, "eventAtomMock")
		val event = mock(JDTEvent, "eventMock")
		when(event.eventType).thenReturn(eventType)
		when(event.eventAtom).thenReturn(eventAtom)
		when(eventAtom.element).thenReturn(javaElement)
		
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
		val javaElement = mock(IJavaElement, "javaElementMock")
		val eventAtom = mock(JDTEventAtom, "eventAtomMock")
		val event = mock(JDTEvent, "eventMock")
		when(event.eventType).thenReturn(eventType)
		when(event.eventAtom).thenReturn(eventAtom)
		when(eventAtom.element).thenReturn(javaElement)
		
		// Exisiting activation with same event atom
		val Activation<JDTEventAtom> activation = mock(Activation, "activationMock")
		when(activation.atom).thenReturn(eventAtom)
		when(ruleInstance.allActivations).thenReturn(#[activation])
		
		// Act
		eventHandler.handleEvent(event)
		
		// Assert
		// New activation is NOT created
		verify(ruleInstance, never).createActivation(any(JDTEventAtom))
		// Life cycle transition is called on the new activation
		verify(ruleInstance).activationStateTransition(activation, eventType)
	}
}
