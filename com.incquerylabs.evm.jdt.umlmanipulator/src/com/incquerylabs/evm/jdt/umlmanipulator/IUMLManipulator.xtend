package com.incquerylabs.evm.jdt.umlmanipulator

interface IUMLManipulator {
	def void createElement(String fqn, UMLElementType elementType)
	def void deleteElement(String fqn, UMLElementType elementType)
}