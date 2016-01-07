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
import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import org.eclipse.incquery.runtime.api.IncQueryEngine

class UMLElementLocator implements IUMLElementLocator {
	extension val UmlQueries umlQueries = UmlQueries::instance
	val IncQueryEngine engine
	
	val Model umlModel
	
	new(Model umlModel, IncQueryEngine engine) {
		this.umlModel = umlModel
		this.engine = engine
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
		val results = engine.qualifiedNamedElement.getAllValuesOfelement(prefixedUmlQualifiedName.toString)
		return results.filter(clazz).head
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
			val results = engine.qualifiedNamedElement.getAllValuesOfelement(prefixedUmlQualifiedName.toString)
			return results.head
		}
	}
	
	private def toModelNamePrefixedQualifiedName(QualifiedName qualifiedName) {
		val umlQualifiedName = UMLQualifiedName::create(qualifiedName)
		val correctedUmlQualifiedName = UMLQualifiedName.create('''«umlModel.qualifiedName»::«umlQualifiedName»''')
		return correctedUmlQualifiedName
	}
}