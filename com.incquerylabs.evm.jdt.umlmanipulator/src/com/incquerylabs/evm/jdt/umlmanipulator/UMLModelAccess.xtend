package com.incquerylabs.evm.jdt.umlmanipulator

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Operation
import java.util.Optional
import org.eclipse.uml2.uml.PrimitiveType

interface UMLModelAccess {
	
	/**
	 * Return the UML Package with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<org.eclipse.uml2.uml.Package> findPackage(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Package with the given qualified name if it exists, create otherwise. 
	 */
	def org.eclipse.uml2.uml.Package ensurePackage(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Package from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removePackage(org.eclipse.uml2.uml.Package pckg)

	/**
	 * Return the UML Class with the given qualified name, Optional.absent otherwise. 
	 */
	def Optional<org.eclipse.uml2.uml.Class> findClass(QualifiedName qualifiedName)
	
	/**
	 * Return the UML Class with the given qualified name if it exists, create otherwise. 
	 */
	def org.eclipse.uml2.uml.Class ensureClass(QualifiedName qualifiedName)
	
	/**
	 * Remove the UML Class from the model, return true if change occurred, false otherwise. 
	 */
	def boolean removeClass(org.eclipse.uml2.uml.Class clss)
	
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