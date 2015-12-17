package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import java.util.List
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment

class TypeVisitor extends ASTVisitor {
	val IUMLManipulator manipulator
	
	new(IUMLManipulator manipulator) {
		this.manipulator = manipulator
	}
	
	override visit(TypeDeclaration node) {
		val binding = node.resolveBinding
		if(binding != null) {
			val fqn = JDTQualifiedName::create(binding.qualifiedName)
			manipulator.createClass(fqn)
		}
		
		
		super.visit(node)
		return true
	}
	
	override visit(FieldDeclaration node) {
		val type = node.type
		val binding = type.resolveBinding
		
		val containingType = node.parent as TypeDeclaration
		val parentBinding = containingType.resolveBinding
		
		if(binding != null && parentBinding != null) {
			val typeFqn = JDTQualifiedName::create(binding.qualifiedName)
			
			val List<VariableDeclarationFragment> fragments = node.fragments
			fragments.forEach[ fragment |
				val javaFieldFqn = JDTQualifiedName::create('''«parentBinding.qualifiedName».«fragment.name.fullyQualifiedName»''')
				manipulator.createAssociation(javaFieldFqn, typeFqn)
			]
		}
		
		super.visit(node)
		return true
	}
	
}