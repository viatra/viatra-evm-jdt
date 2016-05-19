package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import org.eclipse.xtend.lib.annotations.Accessors

class BidirectionalSynchronization {

	JDTUMLTransformation java2umlTransformation

	@Accessors
	UMLJavaSynchronizationDirection dir = UMLJavaSynchronizationDirection.NEITHER

	new(JDTUMLTransformation java2uml) {
		java2umlTransformation = java2uml
	}

	def allowJava2UML(){
		println("Allow Java2UML")
		java2umlTransformation?.enableSynchronization
		dir = UMLJavaSynchronizationDirection.JAVA2UML
	}
	
	def dispose() {
	    java2umlTransformation?.dispose
	    dir = UMLJavaSynchronizationDirection.NEITHER
	}
}

public enum UMLJavaSynchronizationDirection {
	UML2JAVA, JAVA2UML, BOTH, NEITHER
}