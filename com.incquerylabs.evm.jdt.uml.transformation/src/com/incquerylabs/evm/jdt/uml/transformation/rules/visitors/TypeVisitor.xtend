package com.incquerylabs.evm.jdt.uml.transformation.rules.visitors

import com.google.common.base.Optional
import com.google.common.collect.ImmutableList
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.List
import java.util.Set
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.BodyDeclaration
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.ITypeBinding
import org.eclipse.jdt.core.dom.MethodDeclaration
import org.eclipse.jdt.core.dom.Modifier
import org.eclipse.jdt.core.dom.SingleVariableDeclaration
import org.eclipse.jdt.core.dom.Type
import org.eclipse.jdt.core.dom.TypeDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.BehavioredClassifier
import org.eclipse.uml2.uml.Classifier
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Interface
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.ParameterDirectionKind
import org.eclipse.uml2.uml.TypedElement
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.VisibilityKind
import org.eclipse.viatra.integration.evm.jdt.util.JDTQualifiedName
import org.eclipse.viatra.integration.evm.jdt.util.QualifiedName
import org.eclipse.xtend.lib.annotations.Accessors

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
			val umlType = ensureType(node, fqn)
			umlType.removeSubelements
			umlType.setVisibility(node)
			umlType.isAbstract = node.isAbstract
			
			val superclassType = Optional::fromNullable(node.superclassType)
			superclassType.asSet.forEach[
				umlType.addGeneralization(it)
			]
			if(umlType instanceof BehavioredClassifier) {
				node.superInterfaceTypes.forEach[
					umlType.addInterfaceRealization(it)
				]
			} else if (umlType instanceof Interface){
				node.superInterfaceTypes.forEach[
					umlType.addGeneralization(it)
				]
			}
			
			visitedElements.add(umlType)
		}
		
		super.visit(node)
		return true
	}
	
	private def Classifier ensureType(TypeDeclaration node, QualifiedName qualifiedName) {
		if(node.isInterface) {
			return ensureInterface(qualifiedName)
		} else {
			return ensureClass(qualifiedName)
		}
	}
	
	override visit(FieldDeclaration node) {
		val containingType = node.parent as TypeDeclaration
		val List<VariableDeclarationFragment> variables = node.fragments
		
		val associations = variables.map[
			transformField(containingType)
		]
		
		val type = node.type
		associations.forEach[asSet.forEach[
			val target = targetEnd
			val typeBinding = target.setType(type)
			target.isStatic = node.isStatic 
			memberEnds.forEach[
				lower = 0
				upper = 1
				setVisibility(node)
			]
			target.lower = 0
			target.upper = typeBinding.upperBound
			setVisibility(node)
		]]
		
		super.visit(node)
		return true
	}
	
	override visit(SingleVariableDeclaration node) {
		val containingMethod = node.parent
		
		if(containingMethod instanceof MethodDeclaration) {
			val umlParameter = node.transformParameter(containingMethod)
			val type = node.type
			umlParameter.asSet.forEach[
				lower = 0
				val typeBinding = setType(type)
				upper = typeBinding.upperBound
			]
		}
		
		super.visit(node)
		return true
	}
	
	override visit(MethodDeclaration node) {
		val containingType = node.parent as TypeDeclaration
		val umlOperation = node.transformOperation(containingType)
		umlOperation.asSet.forEach[ operation |
			visitedElements.add(operation)
			
			operation.setVisibility(node)
			operation.isAbstract = node.isAbstract
			operation.isStatic = node.isStatic
			val operationBody = node.transformOperationBody(containingType)
			operationBody.asSet.forEach[
				operation.methods += it
			]
		]
		
		super.visit(node)
		return true
	}
	
	private def addGeneralization(Classifier umlType, Type superclassType) {
		if(superclassType == null) {
			return Optional::absent
		}
		
		val superclassTypeBinding = superclassType.resolveBinding
		if(superclassTypeBinding != null) {
			val superclassQualifiedName = JDTQualifiedName::create(superclassTypeBinding.qualifiedName)
			val superclassUmlType = getType(superclassQualifiedName, superclassTypeBinding)
			if(superclassUmlType instanceof Classifier) {
				val generalization = umlFactory.createGeneralization => [
					general = superclassUmlType
					specific = umlType
				]
				return Optional::of(generalization)
			}
		}
		return Optional::absent
	}
	
	private def addInterfaceRealization(BehavioredClassifier umlClass, Type interfaceType) {
		if(interfaceType == null) {
			return Optional::absent
		}
		
		val interfaceTypeBinding = interfaceType.resolveBinding
		if(interfaceTypeBinding != null) {
			val interfaceQualifiedName = JDTQualifiedName::create(interfaceTypeBinding.qualifiedName)
			val interfaceUmlType = getType(interfaceQualifiedName, interfaceTypeBinding)
			if(interfaceUmlType instanceof Interface) {
				val interfaceRealization = umlFactory.createInterfaceRealization => [
					contract = interfaceUmlType
					implementingClassifier = umlClass
				]
				return Optional::of(interfaceRealization)
			}
		}
		return Optional::absent
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
				lower = 0
			]
			val typeBinding = returnParameter.setType(returnType)
			returnParameter.upper = typeBinding.upperBound
			if(returnParameter.type != null){
				umlOperation.ownedParameters += returnParameter
			} else {
				returnParameter.destroy
			}
			
			return Optional::of(umlOperation)
		}
		return Optional::absent
	}
	
	private def getUpperBound(ITypeBinding typeBinding) {
		if(typeBinding != null && typeBinding.array) {
			return -1
		} else {
			return 1
		}
	}
	
	private def removeSubelements(Operation umlOperation) {
		ImmutableList::copyOf(umlOperation.ownedParameters).forEach[
			destroy
		]
		ImmutableList::copyOf(umlOperation.methods).forEach[
			destroy
		]
	}
	
	private def removeSubelements(Classifier umlType) {
		ImmutableList::copyOf(umlType.generalizations).forEach[
			destroy
		]
		if(umlType instanceof BehavioredClassifier){
			ImmutableList::copyOf(umlType.interfaceRealizations).forEach[
				destroy
			]
		}
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
		return Optional::absent
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
		return Optional::absent
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
		return Optional::absent
	}
	
	/**
	 * Returns the resolved TypeBinding if possible, null otherwise
	 */
	private def setType(TypedElement typedElement, Type type) {
		if(type == null) {
			typedElement.type = null
			return null
		}
		
		val typeBinding = type.resolveBinding
		if(typeBinding != null) {
			var typeName = typeBinding.qualifiedName
			if(typeBinding.isArray){
				val elementType = typeBinding.elementType
				typeName = elementType.qualifiedName
			}
			val typeFqn = JDTQualifiedName::create(typeName)
			val associationType = getType(typeFqn, typeBinding)
			typedElement.type = associationType
		}
		return typeBinding
	}
	
	private def setVisibility(NamedElement element, BodyDeclaration node) {
		element.visibility = switch modifiers : node.getModifiers {
			case Modifier::isPublic(modifiers): VisibilityKind::PUBLIC_LITERAL
			case Modifier::isProtected(modifiers): VisibilityKind::PROTECTED_LITERAL
			case Modifier::isPrivate(modifiers): VisibilityKind::PRIVATE_LITERAL
			default: VisibilityKind::PACKAGE_LITERAL
		}
	}
	
	private def isAbstract(BodyDeclaration node){
		val modifiers = node.getModifiers
		if(Modifier::isAbstract(modifiers)) {
			return true
		} else {
			return false
		}
	}
	
	private def isStatic(BodyDeclaration node) {
		val modifiers = node.getModifiers
		if(Modifier::isStatic(modifiers)) {
			return true
		} else {
			return false
		}
	}
	
	private def getType(QualifiedName qualifiedName, ITypeBinding element) {
		if(qualifiedName.toString == "void") {
			return null
		}
		val existingType = qualifiedName.findType
		// if not an existing type (e.g. primitive type or interface), ensure there is such a class
		val umlType = existingType.or[
			if(element.interface){
				ensureInterface(qualifiedName)
			} else {
				ensureClass(qualifiedName)
			}
		]
		return umlType
	}
	
	def void clearVisitedElements() {
		visitedElements.clear
	}
	
}