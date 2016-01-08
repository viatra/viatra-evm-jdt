package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.google.common.collect.ImmutableList
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import java.util.Set
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.MethodDeclaration
import org.eclipse.jdt.core.dom.SingleVariableDeclaration
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.ParameterDirectionKind
import org.eclipse.uml2.uml.Type
import org.eclipse.uml2.uml.TypedElement
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional
import org.eclipse.uml2.uml.Operation

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
		val containingType = node.parent as TypeDeclaration
		val List<VariableDeclarationFragment> variables = node.fragments
		val associations = variables.map[
			transformField(containingType)
		]
		
		val type = node.type
		associations.forEach[ifPresent[
			targetEnd.setType(type)
		]]
		
		super.visit(node)
		return true
	}
	
	override visit(SingleVariableDeclaration node) {
		val containingMethod = node.parent
		
		if(containingMethod instanceof MethodDeclaration) {
			val umlParameter = node.transformParameter(containingMethod)
			val type = node.type
			umlParameter.ifPresent[
				setType(type)
			]
		}
		
		super.visit(node)
		return true
	}
	
	override visit(MethodDeclaration node) {
		val containingType = node.parent as TypeDeclaration
		
		val umlOperation = node.transformOperation(containingType)
		
		umlOperation.ifPresent[ operation |
			visitedElements.add(operation)
			
			val operationBody = node.transformOperationBody(containingType)
			operationBody.ifPresent[
				operation.methods += it
			]
		]
		
		super.visit(node)
		return true
	}
	
	private def Optional<Operation> transformOperation(MethodDeclaration node, TypeDeclaration containingType) {
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null) {
			val parentClassName = parentBinding.qualifiedName
			val javaMethodFqn = JDTQualifiedName::create('''«parentClassName».«node.name.fullyQualifiedName»''')
			val umlOperation = ensureOperation(javaMethodFqn)
			umlOperation.removeSubelements
			
			val returnType = node.returnType2
			val returnParameter = umlFactory.createParameter => [
				name = "__returnvalue"
				direction = ParameterDirectionKind.RETURN_LITERAL
			]
			returnParameter.setType(returnType)
			umlOperation.ownedParameters += returnParameter
			
			return Optional::of(umlOperation)
		}
		return Optional::empty
	}
	
	private def removeSubelements(Operation umlOperation) {
		ImmutableList::copyOf(umlOperation.ownedParameters).forEach[
			destroy
		]
		ImmutableList::copyOf(umlOperation.methods).forEach[
			destroy
		]
	}
	
	private def transformOperationBody(MethodDeclaration node, TypeDeclaration containingType) {
		val parentBinding = containingType.resolveBinding
		val body = node.body
		
		if(parentBinding != null && body != null) {
			val parentClassName = parentBinding.qualifiedName
			val behavior = umlFactory.createOpaqueBehavior => [
				name = '''«node.name.fullyQualifiedName»__body'''
				languages += "Java"
				bodies += body.toString
			]
			val parentClassQualifiedName = JDTQualifiedName::create(parentClassName)
			val parentClass = ensureClass(parentClassQualifiedName)
			parentClass.ownedBehaviors += behavior
			return Optional::of(behavior)
		}
		return Optional::empty
	}
	
	private def getTargetEnd(Association association) {
		association.memberEnds.filter[ targetEnd | 
			!association.ownedEnds.contains(targetEnd) ||
			association.navigableOwnedEnds.contains(targetEnd)
		].head
	}
	
	private def transformField(VariableDeclarationFragment variable, TypeDeclaration containingType) {
		val parentBinding = containingType.resolveBinding
		if(parentBinding != null) {
			val javaFieldFqn = JDTQualifiedName::create('''«parentBinding.qualifiedName».«variable.name.fullyQualifiedName»''')
			val association = ensureAssociation(javaFieldFqn)
			visitedElements.add(association)
			return Optional::of(association)
		}
		return Optional::empty
	}
	
	private def transformParameter(SingleVariableDeclaration node, MethodDeclaration containingMethod) {
		val containingClass = containingMethod.parent as TypeDeclaration
		val containingClassBinding = containingClass?.resolveBinding
		if(containingClassBinding != null) {
			val methodName = containingMethod.name
			val methodQualifiedName = JDTQualifiedName::create('''«containingClassBinding.qualifiedName».«methodName»''')
			val umlOperation = ensureOperation(methodQualifiedName)
			val umlParameter = umlFactory.createParameter => [
				name = node.name.fullyQualifiedName
			]
			umlOperation.ownedParameters += umlParameter
			return Optional::of(umlParameter)
		}
		return Optional::empty
	}
	
	private def setType(TypedElement typedElement, org.eclipse.jdt.core.dom.Type type) {
		if(type == null) {
			typedElement.type = null
			return
		}
		
		val typeBinding = type.resolveBinding
		if(typeBinding != null) {
			val typeFqn = JDTQualifiedName::create(typeBinding.qualifiedName)
			val associationType = getClassOrPrimitiveType(typeFqn)
			typedElement.type = associationType
		}
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