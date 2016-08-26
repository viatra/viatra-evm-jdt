package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.google.common.collect.ImmutableList
import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.UMLElementLocator
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import java.util.Optional
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Interface
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.PrimitiveType
import org.eclipse.uml2.uml.Type
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.viatra.query.runtime.api.ViatraQueryEngine

class UMLModelAccessImpl implements UMLModelAccess {
	
	extension val Logger logger = Logger.getLogger(this.class)
	extension val UMLFactory umlFactory = UMLFactory.eINSTANCE
	val Model model
	val IUMLElementLocator locator
	val ViatraQueryEngine engine
	
	
	new(Model umlModel, ViatraQueryEngine engine) {
		this.model = umlModel
		this.engine = engine
		this.locator = new UMLElementLocator(umlModel, engine)
		logger.level = Level.DEBUG
	}
	
	override findPackage(QualifiedName qualifiedName) {
		val packageFragment = locator.locatePackage(qualifiedName)
		return Optional.ofNullable(packageFragment)
	}
	
	override ensurePackage(QualifiedName qualifiedName) {
		val existingPackage = qualifiedName.findPackage
		
		return existingPackage.orElseGet[
			createPackage(qualifiedName)
		]
	}
	
	private def createPackage(QualifiedName qualifiedName) {
		val parentFqn = qualifiedName.parent
		val parentPackage = parentFqn.map[
			ensurePackage
		].orElseGet[locator.UMLModel]
		
		val packageFragment = umlFactory.createPackage() => [
			name = qualifiedName.name
		]
		
		parentPackage.packagedElements += packageFragment
		debug('''Created package «qualifiedName»''')
		packageFragment
	}
	
	override removePackage(Package pckg) {
		if(pckg.eContainer == null){
			return false;
		}
		
		val fqn = pckg.qualifiedName
		pckg.destroy
		debug('''Deleted package «fqn»''')
		return true
	}
	
	override findType(QualifiedName qualifiedName) {
		val primitiveType = findPrimitiveType(qualifiedName)
		if(primitiveType.isPresent) {
			return primitiveType.map[it as Type]
		}
		val type = locator.locateType(qualifiedName)
		return Optional.ofNullable(type)
	}
	
	override findClass(QualifiedName qualifiedName) {
		val clsFragment = locator.locateClass(qualifiedName)
		return Optional.ofNullable(clsFragment)
	}
	
	override findPrimitiveType(QualifiedName qualifiedName) {
		val javaPrimitiveTypesUri = UMLResource.JAVA_PRIMITIVE_TYPES_LIBRARY_URI
		val umlPrimitiveTypesUri = UMLResource.UML_PRIMITIVE_TYPES_LIBRARY_URI
		
		val javaPrimitiveTypesResource = model.eResource.resourceSet.getResource(URI.createURI(javaPrimitiveTypesUri), true)
		val umlPrimitiveTypesResource = model.eResource.resourceSet.getResource(URI.createURI(umlPrimitiveTypesUri), true)
		
		val fqn = qualifiedName.toString
		
		if(fqn.equals("java.lang.String")){
			val stringType = umlPrimitiveTypesResource.allContents.filter(PrimitiveType).findFirst[
				name.equals("String")
			]
			return Optional.ofNullable(stringType)
		}
		
		val javaPrimitiveType = javaPrimitiveTypesResource.allContents.filter(PrimitiveType).findFirst[
			name.equals(qualifiedName.name)
		]
		return Optional.ofNullable(javaPrimitiveType)		
		
	}
	
	override ensureClass(QualifiedName qualifiedName) {
		val existingClass = qualifiedName.findClass
		
		return existingClass.orElseGet[
			val existingType = qualifiedName.findType
			if(existingType.present){
				val typeValue = existingType.get
				// if enums are supported, extend this part
				if(typeValue instanceof Interface){
					removeInterface(typeValue)
				}
			}
			createClass(qualifiedName)
		]
	}
	
	private def createClass(QualifiedName qualifiedName) {
		val parentFqn = qualifiedName.parent
		
		val parent = parentFqn.map[
			ensurePackage
		].orElseGet[locator.UMLModel]
		
		val umlClass = createClass => [
			name = qualifiedName.name
		]
		
		parent.packagedElements += umlClass
		debug('''Created class «qualifiedName»''')
		return umlClass
	}
	
	override removeClass(Class clss) {
		if(clss.eContainer == null){
			return false;
		}
		
		val fqn = clss.qualifiedName
		clss.destroy
		debug('''Deleted class «fqn»''')
		return true
	}
	
	override findInterface(QualifiedName qualifiedName) {
		val umlInterface = locator.locateInterface(qualifiedName)
		return Optional.ofNullable(umlInterface)
	}
	
	override ensureInterface(QualifiedName qualifiedName) {
		val existingInterface = qualifiedName.findInterface
		
		return existingInterface.orElseGet[
			val existingType = qualifiedName.findType
			if(existingType.present){
				val typeValue = existingType.get
				// if enums are supported, extend this part
				if(typeValue instanceof Class){
					removeClass(typeValue)
				}
			}
			createInterface(qualifiedName)
		]
	}
	
	private def createInterface(QualifiedName qualifiedName) {
		val parentFqn = qualifiedName.parent
		
		val parent = parentFqn.map[
			ensurePackage
		].orElseGet[locator.UMLModel]
		
		val umlInterface = createInterface => [
			name = qualifiedName.name
		]
		
		parent.packagedElements += umlInterface
		debug('''Created interface «qualifiedName»''')
		return umlInterface
	}
	
	override removeInterface(Interface umlInterface) {
		if(umlInterface.eContainer == null){
			return false;
		}
		
		val fqn = umlInterface.qualifiedName
		umlInterface.destroy
		debug('''Deleted interface «fqn»''')
		return true
	}
	
	override findAssociation(QualifiedName qualifiedName) {
		val association = locator.locateAssociation(qualifiedName)
		return Optional.ofNullable(association)
	}
	
	override ensureAssociation(QualifiedName qualifiedName) {
		val existingAssociation = qualifiedName.findAssociation
		
		return existingAssociation.orElseGet[
			createAssociation(qualifiedName)
		]
	}
	
	private def createAssociation(QualifiedName qualifiedName) {
		val parentFqn = qualifiedName.parent
		val parent = parentFqn.flatMap[
			findClass
		]
		
		val umlAssociation = parent.map[ parentClass |
			val association = createAssociation => [
				it.name = '''«parentClass.name»_«qualifiedName.name»'''
			]
			val navigableEnd = createProperty => [
				it.name = qualifiedName.name
				it.association = association
			]
			val oppositeEnd = createProperty => [
				it.name = '''«qualifiedName.name»_opposite'''
				it.association = association
				it.type = parentClass
			]
			parentClass.ownedAttributes += navigableEnd
			association.ownedEnds += oppositeEnd
			parentClass.package.packagedElements += association
			
			debug('''Created association «qualifiedName»''')
			association
		]
		
		return umlAssociation.orElseThrow[new RuntimeException('''Was not able to create UML association: «qualifiedName»''')]
	}
	
	override removeAssociation(Association association) {
		association.memberEnds.forEach[
			destroy
		]
		if(association.eContainer == null){
			return false;
		}
		
		val fqn = association.qualifiedName
		association.destroy
		debug('''Deleted association «fqn»''')
		return true
	}
	
	override findOperation(QualifiedName qualifiedName) {
		val operation = locator.locateOperation(qualifiedName)
		return Optional.ofNullable(operation)
	}
	
	override ensureOperation(QualifiedName qualifiedName) {
		val existingOperation = qualifiedName.findOperation
		
		return existingOperation.orElseGet[
			createOperation(qualifiedName)
		]
	}
	
	private def createOperation(QualifiedName qualifiedName) {
		val parentFqn = qualifiedName.parent
		val parent = parentFqn.flatMap[
			findType
		]
		
		val umlOperation = parent.map[ parentClass |
			val operation = createOperation => [
				it.name = '''«qualifiedName.name»'''
			]
			// yes, UML has a different feature for owned operations of Class and Interface, how convenient
			if(parentClass instanceof Class){
				parentClass.ownedOperations += operation
			} else if(parentClass instanceof Interface) {
				parentClass.ownedOperations += operation
			}
			
			debug('''Created operation «qualifiedName»''')
			operation
		]
		
		return umlOperation.orElseThrow[new RuntimeException('''Was not able to create UML operation: «qualifiedName»''')]
	}
	
	override removeOperation(Operation operation) {
		val operationBodies = ImmutableList::copyOf(operation.methods)
		operationBodies.forEach[
			destroy
		]
		
		if(operation.eContainer == null){
			return false;
		}
		
		val fqn = operation.qualifiedName
		operation.destroy
		debug('''Deleted operation «fqn»''')
		return true
	}
	
}
