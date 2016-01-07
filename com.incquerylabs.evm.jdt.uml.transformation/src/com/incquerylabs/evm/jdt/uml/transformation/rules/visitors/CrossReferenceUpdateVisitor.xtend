package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.eclipse.jdt.core.dom.TypeDeclaration

class CrossReferenceUpdateVisitor extends TypeVisitor {
	new(UMLModelAccess umlModelAccess) {
		super(umlModelAccess)
	}
	
	override visit(TypeDeclaration node) {
		return true
	}
}