package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.UMLElementLocator
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.UMLFactory
import java.util.Optional

class UMLModelAccessImpl implements UMLModelAccess {
	
	extension val Logger logger = Logger.getLogger(this.class)
	extension val UMLFactory umlFactory = UMLFactory.eINSTANCE
	val Model model
	val IUMLElementLocator locator
	static val umlQueries = UmlQueries::instance
	val IncQueryEngine engine
	
	
	new(Model umlModel, IncQueryEngine engine) {
		this.model = umlModel
		this.locator = new UMLElementLocator(umlModel)
		this.engine = engine
		logger.level = Level.DEBUG
	}
	
	override findPackage(QualifiedName qualifiedName) {
		val packageFragment = locator.locatePackage(qualifiedName)
		return Optional.ofNullable(packageFragment)
	}
	
	override ensurePackage(QualifiedName qualifiedName) {
		val existingPackage = qualifiedName.findPackage
		if(existingPackage.present){
			return existingPackage.get
		}
		
		if(!qualifiedName.parent.isPresent) {
			throw new IllegalArgumentException("Cannot create root package")
		}
		val parentFqn = qualifiedName.parent.get
		
		val packageFragment = umlFactory.createPackage() => [
			name = qualifiedName.name
		]
		val parentPackage =  parentFqn.findPackage
		if(parentPackage.present) {
			parentPackage.get.packagedElements += packageFragment
			debug('''Created package «qualifiedName»''')
		} else {
			throw new IllegalArgumentException("Package must be in another package")
		}
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
	
	override findClass(QualifiedName qualifiedName) {
		val clsFragment = locator.locateClass(qualifiedName)
		return Optional.ofNullable(clsFragment)
	}
	
	override ensureClass(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
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
	
	override findAssociation(QualifiedName qualifiedName) {
		val association = locator.locateAssociation(qualifiedName)
		return Optional.ofNullable(association)
	}
	
	override ensureAssociation(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override removeAssociation(Association association) {
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
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override removeOperation(Operation operation) {
		if(operation.eContainer == null){
			return false;
		}
		
		val fqn = operation.qualifiedName
		operation.destroy
		debug('''Deleted operation «fqn»''')
		return true
	}
	
}