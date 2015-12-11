package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.TypeDeclaration

class TypeVisitor extends ASTVisitor {
	val IUMLManipulator manipulator
	
	new(IUMLManipulator manipulator) {
		this.manipulator = manipulator
	}
	
	override visit(TypeDeclaration node) {
		val fqn = JDTQualifiedName::create(node.resolveBinding.qualifiedName)
		manipulator.createClass(fqn)
		
		
		super.visit(node)
		return false
	}
	
}