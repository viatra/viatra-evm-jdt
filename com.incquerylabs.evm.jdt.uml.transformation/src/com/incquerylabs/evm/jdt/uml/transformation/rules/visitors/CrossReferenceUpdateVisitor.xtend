package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment

class CrossReferenceUpdateVisitor extends ASTVisitor {
	extension val UMLModelAccess umlModelAccess
	
	new(UMLModelAccess umlModelAccess) {
		this.umlModelAccess = umlModelAccess
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
				val association = ensureAssociation(javaFieldFqn)
				val umlType = findClass(typeFqn)
				umlType.ifPresent[
					val targetEnd = association.memberEnds.filter[ targetEnd | 
						!association.ownedEnds.contains(targetEnd) ||
						association.navigableOwnedEnds.contains(targetEnd)
					].head
					
					targetEnd.type = it
				]
			]
		}
		
		super.visit(node)
		return true
	}
	
}