package com.incquerylabs.evm.jdt.test

import org.junit.Before
import org.mockito.MockitoAnnotations
import org.junit.Test
import com.incquerylabs.evm.jdt.application.JDTEventDrivenApp
import org.mockito.InjectMocks
import org.omg.DynamicAny.AnySeqHelper

import static org.mockito.Mockito.*
import com.incquerylabs.evm.jdt.JDTActivationState

/**
 * Class under test: {@link JDTEventDrivenApp}
 */
class JDTEventDrivenAppTest {
	@InjectMocks JDTEventDrivenApp app
	
	@Before
	def void initMocks(){
		MockitoAnnotations.initMocks(this);
	}
	
	@Test
	def void addLoggerJob_activationState_jobAdded(){
		// Arrange
		
		// Act
		
		// Assert
	}
}