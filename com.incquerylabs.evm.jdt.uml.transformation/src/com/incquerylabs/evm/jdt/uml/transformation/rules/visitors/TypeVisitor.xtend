package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import java.util.Set
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.uml2.uml.Element
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.jdt.core.dom.MethodDeclaration
import org.eclipse.jdt.core.dom.SingleVariableDeclaration
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.ParameterDirectionKind
import com.google.common.collect.ImmutableList
import org.eclipse.uml2.uml.Type
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName

class TypeVisitor extends ASTVisitor {
	val UMLFactory umlFactory = UMLFactory::eINSTANCE
	extension val UMLModelAccess umlModelAccess
	
	@Accessors(PUBLIC_GETTER)
	val Set<Element> visitedElements = newHashSet
	
	new(UMLModelAccess umlModelAccess) {
		this.umlModelAccess = umlModelAccess
	}
	
	override visit(TypeDeclaration node) {
		val binding = node.resolveBinding
		if(binding != null) {
			val fqn = JDTQualifiedName::create(binding.qualifiedName)
			val umlClass = ensureClass(fqn)
			visitedElements.add(umlClass)
		}
		
		
		super.visit(node)
		return true
	}
	
	override visit(FieldDeclaration node) {
		val type = node.type
		val binding = type.resolveBinding
		
		val containingType = node.parent as TypeDeclaration
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null) {
			val List<VariableDeclarationFragment> variables = node.fragments
			variables.forEach[ variable |
				val javaFieldFqn = JDTQualifiedName::create('''«parentBinding.qualifiedName».«variable.name.fullyQualifiedName»''')
				val association = ensureAssociation(javaFieldFqn)
				visitedElements.add(association)
				
				if(binding != null) {
					val typeFqn = JDTQualifiedName::create(binding.qualifiedName)
					val associationType = getClassOrPrimitiveType(typeFqn)
					val targetEnd = association.memberEnds.filter[ targetEnd | 
						!association.ownedEnds.contains(targetEnd) ||
						association.navigableOwnedEnds.contains(targetEnd)
					].head
					targetEnd.type = associationType
				}
			]
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
					val umlType = getClassOrPrimitiveType(typeFqn)
					umlParameter.type = umlType
				}
				umlOperation.ownedParameters += umlParameter
			}
		}
		
		super.visit(node)
		return true
	}
	
	override visit(MethodDeclaration node) {
		val containingType = node.parent as TypeDeclaration
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null) {
			val parentClassName = parentBinding.qualifiedName
			val javaMethodFqn = JDTQualifiedName::create('''«parentClassName».«node.name.fullyQualifiedName»''')
			val umlOperation = ensureOperation(javaMethodFqn)
			ImmutableList::copyOf(umlOperation.ownedParameters).forEach[
				destroy
			]
			ImmutableList::copyOf(umlOperation.methods).forEach[
				destroy
			]
			val returnTypeBinding = node.returnType2?.resolveBinding
			if(returnTypeBinding != null) {
				val typeFqn = JDTQualifiedName::create(returnTypeBinding.qualifiedName)
				umlOperation.ownedParameters += umlFactory.createParameter => [
					name = "__returnvalue"
					direction = ParameterDirectionKind.RETURN_LITERAL
					val umlType = getClassOrPrimitiveType(typeFqn)
					type = umlType
				]
			}
			val body = node.body
			if(body != null) {
				val behavior = umlFactory.createOpaqueBehavior => [
					name = '''«umlOperation.name»__body'''
					languages += "Java"
					bodies += body.toString
				]
				val parentClassQualifiedName = JDTQualifiedName::create(parentClassName)
				val parentClass = ensureClass(parentClassQualifiedName)
				parentClass.ownedBehaviors += behavior
				umlOperation.methods += behavior
			}
			
			visitedElements.add(umlOperation)
		}
		
		super.visit(node)
		return true
	}
	
	private def getClassOrPrimitiveType(QualifiedName qualifiedName) {
		if(qualifiedName.toString == "void") {
			return null
		}
		val primitiveType = qualifiedName.findPrimitiveType
		// if not a primitive type, ensure there is such a class
		val umlType = primitiveType.map[it as Type].orElseGet[ensureClass(qualifiedName)]
		return umlType
	}
	
	def void clearVisitedElements() {
		visitedElements.clear
	}
	
}