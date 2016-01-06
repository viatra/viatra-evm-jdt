package com.incquerylabs.evm.jdt.fqnutil.impl

import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Property

class UMLElementLocator implements IUMLElementLocator {
	
	val Model umlModel
	
	new(Model umlModel) {
		this.umlModel = umlModel
	}
	
	override locatePackage(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Package)
	}
	
	override locateClass(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Class)
	}
	
	override locateAssociation(QualifiedName qualifiedName) {
		val attribute = locateElement(qualifiedName, Property)
		return attribute?.association
	}
	
	override locateOperation(QualifiedName qualifiedName) {
		locateElement(qualifiedName, Operation)
	}
	
	def <T extends NamedElement>locateElement(QualifiedName qualifiedName, java.lang.Class<T> clazz){
		val prefixedUmlQualifiedName = qualifiedName.toModelNamePrefixedQualifiedName
		// TODO this is extremely inefficient! use EIQ instead
		umlModel.allOwnedElements.filter(clazz).findFirst[element|
			UMLQualifiedName.create(element.qualifiedName) == prefixedUmlQualifiedName
		]
	}
	
	override getUMLModel() {
		umlModel
	}
	
	override locateElement(QualifiedName qualifiedName) {
		val prefixedUmlQualifiedName = qualifiedName.toModelNamePrefixedQualifiedName
		val modelQualifiedName = UMLQualifiedName::create(umlModel.qualifiedName)
		if(modelQualifiedName == prefixedUmlQualifiedName) {
			return umlModel
		} else {
			// TODO this is extremely inefficient! use EIQ instead
			umlModel.allOwnedElements.filter(NamedElement).findFirst[element|
				UMLQualifiedName.create(element.qualifiedName) == prefixedUmlQualifiedName
			]
		}
	}
	
	private def toModelNamePrefixedQualifiedName(QualifiedName qualifiedName) {
		val umlQualifiedName = UMLQualifiedName::create(qualifiedName)
		val correctedUmlQualifiedName = UMLQualifiedName.create('''«umlModel.qualifiedName»::«umlQualifiedName»''')
		return correctedUmlQualifiedName
	}
}