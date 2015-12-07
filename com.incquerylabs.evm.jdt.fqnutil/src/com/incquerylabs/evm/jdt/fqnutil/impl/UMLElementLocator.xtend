package com.incquerylabs.evm.jdt.fqnutil.impl

import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Association
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import org.eclipse.uml2.uml.NamedElement

class UMLElementLocator implements IUMLElementLocator {
	
	val Model umlModel
	
	new(Model umlModel) {
		this.umlModel = umlModel
	}
	
	override locatePackage(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Package)
	}
	
	override locateClass(QualifiedName qualifiedName) {
		locateElement(qualifiedName, org.eclipse.uml2.uml.Class)
	}
	
	override locateAssociation(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Association)
	}
	
	override locateOperation(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Operation)
	}
	
	def <T extends NamedElement>locateElement(QualifiedName qualifiedName, Class<T> clazz){
		umlModel.allOwnedElements.filter(clazz).findFirst[element|
			UMLQualifiedName.create(element.qualifiedName) == qualifiedName
		]
	}
	
	override getUMLModel() {
		umlModel
	}
	
	override locateElement(QualifiedName qualifiedName) {
		val modelQualifiedName = UMLQualifiedName::create(umlModel.qualifiedName)
		if(modelQualifiedName == qualifiedName) {
			return umlModel
		} else {
			umlModel.allOwnedElements.filter(NamedElement).findFirst[element|
				UMLQualifiedName.create(element.qualifiedName) == qualifiedName
			]
		}
	}
	
}