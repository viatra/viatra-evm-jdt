package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import com.incquerylabs.evm.jdt.java.transformation.UMLToJavaTransformation
import org.eclipse.xtend.lib.annotations.Accessors

class BidirectionalSynchronization {

	JDTUMLTransformation java2umlTransformation
	UMLToJavaTransformation uml2javaTransformation

	@Accessors
	com.incquerylabs.evm.jdt.ui.UMLJavaSynchronizationDirection dir = UMLJavaSynchronizationDirection.NEITHER

	new(JDTUMLTransformation java2uml, UMLToJavaTransformation uml2java) {
		java2umlTransformation = java2uml
		uml2javaTransformation = uml2java
	}

	def allowJava2UML(){
		println("Allow Java2UML")
		uml2javaTransformation.disableSynchronization
		java2umlTransformation.enableSynchronization
		dir = UMLJavaSynchronizationDirection.JAVA2UML
	}
	
	def allowUML2Java(){
		println("Allow UML2Java")
		java2umlTransformation.disableSynchronization
		uml2javaTransformation.enableSynchronization
		dir = UMLJavaSynchronizationDirection.UML2JAVA
	}
	
	def dispose() {
	    java2umlTransformation.dispose
	    uml2javaTransformation.dispose
	    dir = UMLJavaSynchronizationDirection.NEITHER
	}
}

public enum UMLJavaSynchronizationDirection {
	UML2JAVA, JAVA2UML, BOTH, NEITHER
}