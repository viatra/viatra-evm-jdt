package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.eclipse.uml2.uml.Model

class UMLManipulator implements IUMLManipulator {
	val Model umlModel
	
	new(Model umlModel) {
		this.umlModel = umlModel
	}
	
	override createClass(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override updateClass(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override deleteClass(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override createAssociation(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override updateAssociation(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override deleteAssociation(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}