package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import com.incquerylabs.evm.jdt.java.transformation.UMLToJavaTransformation

class BidirectionalSynchronization {

	JDTUMLTransformation java2umlTransformation
	UMLToJavaTransformation uml2javaTransformation

	new(JDTUMLTransformation java2uml, UMLToJavaTransformation uml2java) {
		java2umlTransformation = java2uml
		uml2javaTransformation = uml2java
	}

	def allowJava2UML(){
		uml2javaTransformation.disableSynchronization
		java2umlTransformation.enableSynchronization
	}
	
	def allowUML2Java(){
		java2umlTransformation.disableSynchronization
		uml2javaTransformation.enableSynchronization
	}
	
	def allowBoth() {
		java2umlTransformation.enableSynchronization
		uml2javaTransformation.enableSynchronization
	}

}