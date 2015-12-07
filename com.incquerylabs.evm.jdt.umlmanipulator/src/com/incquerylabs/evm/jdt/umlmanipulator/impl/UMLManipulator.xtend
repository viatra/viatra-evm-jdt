package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.UMLElementLocator
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.UMLFactory

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
	
	override createAssociation(QualifiedName fqn, QualifiedName typeUmlQualifiedName) {
		val parentQualifiedName = fqn.parent.get
		val parentClass = locator.locateElement(parentQualifiedName)
		if(parentClass != null) {
			if(parentClass instanceof Class) {
				val association = createAssociation => [
					it.name = fqn.name
				]
				association.ownedEnds += createProperty => [
					it.association = association
					it.type = locator.locateElement(typeUmlQualifiedName) as Class
				]
				association.ownedEnds += createProperty => [
					it.association = association
					it.type = parentClass
				]
				parentClass.package.packagedElements += association
			}
		}
	}
	
	override deleteAssociation(QualifiedName fqn) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override save() {
		model.eResource.save(null)
		trace('''Saved UML resource''')
	}
	
}
