package com.incquerylabs.evm.jdt.umlmanipulator.impl.logger

import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.UMLElementType
import org.apache.log4j.Logger

class UMLManipulationLogger implements IUMLManipulator {
	extension Logger logger = Logger.getLogger(this.class)
	
	override createElement(String fqn, UMLElementType elementType) {
		debug('''Created UML «elementType»: «fqn»''')
	}
	
	override deleteElement(String fqn, UMLElementType elementType) {
		debug('''Deleted UML «elementType»: «fqn»''')
	}
	
}