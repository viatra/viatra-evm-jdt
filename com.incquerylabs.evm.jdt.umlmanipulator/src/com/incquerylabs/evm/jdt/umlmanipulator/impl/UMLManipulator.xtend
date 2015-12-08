package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.UMLElementLocator
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.TypedElement

class UMLManipulator implements IUMLManipulator {
	extension val Logger logger = Logger.getLogger(this.class)
	extension val UMLFactory umlFactory = UMLFactory.eINSTANCE
	val Model model
	val IUMLElementLocator locator
	
	new(Model umlModel) {
		this.model = umlModel
		this.locator = new UMLElementLocator(umlModel)
		logger.level = Level.DEBUG
	}
	
	override createClass(QualifiedName fqn) {
		val umlClass = createClass => [
			name = fqn.name
		]
		if(fqn.parent.isPresent){
			val parent = locator.locateElement(fqn.parent.get)
			if(parent != null) {
				if(parent instanceof Package) {
					parent.packagedElements += umlClass
					debug('''Created UML Class: «fqn»''')
				}
			}
		}
	}
	
	override updateName(QualifiedName fqn) {
		val umlElement = locator.locateElement(fqn)
		if(umlElement != null) {
			umlElement.name = fqn.name
			debug('''Updated UML Element name: «fqn»''')
		}
	}
	
	override deleteClass(QualifiedName fqn) {
		val umlClass = locator.locateElement(fqn)
		if(umlClass != null) {
			umlClass.destroy
			debug('''Deleted UML Class: «fqn»''')
		}
	}
	
	override createAssociation(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val parentQualifiedName = fqn.parent.get
		val parentClass = locator.locateElement(parentQualifiedName)
		if(parentClass != null) {
			if(parentClass instanceof Class) {
				val association = createAssociation => [
					it.name = '''«parentClass.name»_«fqn.name»'''
				]
				val ownedProperty= createProperty => [
					it.name = fqn.name
					it.association = association
					it.type = locator.locateElement(typeQualifiedName) as Class
				]
				val oppositeProperty= createProperty => [
					it.name = '''«fqn.name»_opposite'''
					it.association = association
					it.type = parentClass
				]
				association.ownedEnds += oppositeProperty
				parentClass.ownedAttributes += ownedProperty
				parentClass.package.packagedElements += association
			}
		}
	}
	
	override updateType(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val typedElement = locator.locateElement(fqn)
		if(typedElement instanceof TypedElement) {
			val type = locator.locateElement(typeQualifiedName) as Class
			typedElement.type = type
		}
	}
	
	override deleteAssociation(QualifiedName fqn) {
		val memberEnd = locator.locateElement(fqn)
		if(memberEnd instanceof Property) {
			val association = memberEnd.association
			if(association != null) {
				association.memberEnds.forEach[destroy]
				association.destroy
			}
		}
	}
	
	override save() {
		model.eResource.save(null)
		trace('''Saved UML resource''')
	}
	
}
