package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import java.util.List

class TypeVisitor extends ASTVisitor {
	val IUMLManipulator manipulator
	
	new(IUMLManipulator manipulator) {
		this.manipulator = manipulator
	}
	
	override visit(TypeDeclaration node) {
		val fqn = JDTQualifiedName::create(node.resolveBinding.qualifiedName)
		manipulator.createClass(fqn)
		
		
		super.visit(node)
		return true
	}
	
	override visit(FieldDeclaration node) {
		val type = node.type
		val typeFqn = JDTQualifiedName::create(type.resolveBinding.qualifiedName)
		
		val containingType = node.parent as TypeDeclaration
		val List<VariableDeclarationFragment> fragments = node.fragments
		fragments.forEach[ fragment |
			val fqn = JDTQualifiedName::create('''«containingType.resolveBinding.qualifiedName».«fragment.name.fullyQualifiedName»''')
			manipulator.createAssociation(fqn, typeFqn)
		]
		
		super.visit(node)
		return true
	}
	
}