package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.jdt.core.dom.SingleVariableDeclaration
import org.eclipse.jdt.core.dom.MethodDeclaration
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.ParameterDirectionKind

class CrossReferenceUpdateVisitor extends ASTVisitor {
	val UMLFactory umlFactory = UMLFactory::eINSTANCE
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
				val umlType = ensureClass(typeFqn)
				val targetEnd = association.memberEnds.filter[ targetEnd | 
					!association.ownedEnds.contains(targetEnd) ||
					association.navigableOwnedEnds.contains(targetEnd)
				].head
				
				targetEnd.type = umlType
			]
		}
		
		super.visit(node)
		return true
	}
	
	override visit(MethodDeclaration node) {
		val containingType = node.parent as TypeDeclaration
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null){
			val javaMethodFqn = JDTQualifiedName::create('''«parentBinding.qualifiedName».«node.name.fullyQualifiedName»''')
			val umlOperation = ensureOperation(javaMethodFqn)
			umlOperation.ownedParameters.clear
			val returnTypeBinding = node.returnType2?.resolveBinding
			if(returnTypeBinding != null) {
				val typeFqn = JDTQualifiedName::create(returnTypeBinding.qualifiedName)
				umlOperation.ownedParameters += umlFactory.createParameter => [
					direction = ParameterDirectionKind.RETURN_LITERAL
					type = ensureClass(typeFqn)
				]
			}
		}
		
		super.visit(node)
		return true
	}
	
	override visit(SingleVariableDeclaration node) {
		val containingMethod = node.parent
		
		if(containingMethod instanceof MethodDeclaration) {
			val methodName = containingMethod.name
			val containingClass = containingMethod.parent as TypeDeclaration
			val classBinding = containingClass?.resolveBinding
			if(classBinding != null) {
				val parentQualifiedName = JDTQualifiedName::create('''«classBinding.qualifiedName».«methodName»''')
				val umlOperation = ensureOperation(parentQualifiedName)
				val umlParameter = umlFactory.createParameter => [
					name = node.name.fullyQualifiedName
				]
				val parameterBinding = node.resolveBinding
				if(parameterBinding != null) {
					val typeFqn = JDTQualifiedName::create(parameterBinding.type.qualifiedName)
					val umlType = ensureClass(typeFqn)
					umlParameter.type = umlType
				}
				umlOperation.ownedParameters += umlParameter
			}
		}
		
		super.visit(node)
		return true
	}
	
}