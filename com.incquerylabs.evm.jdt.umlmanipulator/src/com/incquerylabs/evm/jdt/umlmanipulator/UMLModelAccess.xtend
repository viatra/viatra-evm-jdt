package com.incquerylabs.evm.jdt.umlmanipulator

import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Interface
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.PrimitiveType
import org.eclipse.uml2.uml.Type
import org.eclipse.viatra.integration.evm.jdt.util.QualifiedName
import com.google.common.base.Optional

interface UMLModelAccess {
	
	/**
	 * Return the UML Package with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Package> findPackage(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Package with the given qualified name if it exists, create otherwise. 
	 */
	def Package ensurePackage(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Package from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removePackage(Package pckg)

	/**
	 * Return the UML Type with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Type> findType(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Class with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Class> findClass(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Class with the given qualified name if it exists, create otherwise. 
	 */
	def Class ensureClass(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Class from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removeClass(Class clss)

	/**
	 * Return the UML Interface with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Interface> findInterface(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Interface with the given qualified name if it exists, create otherwise. 
	 */
	def Interface ensureInterface(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Interface from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removeInterface(Interface umlInterface)
	
	/**
	 * Return the UML Association with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Association> findAssociation(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Association with the given qualified name if it exists, create otherwise. 
	 */
	def Association ensureAssociation(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Association from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removeAssociation(Association association)
	
	/**
	 * Return the UML Operation with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<Operation> findOperation(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Operation with the given qualified name if it exists, create otherwise. 
	 */
	def Operation ensureOperation(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Operation from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removeOperation(Operation operation)
	
	def Optional<PrimitiveType> findPrimitiveType(QualifiedName qualifiedName)
	
}