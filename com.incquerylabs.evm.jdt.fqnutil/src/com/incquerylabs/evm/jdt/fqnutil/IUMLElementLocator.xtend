package com.incquerylabs.evm.jdt.fqnutil

import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Type
import org.eclipse.uml2.uml.Interface

interface IUMLElementLocator {
	def Package locatePackage(QualifiedName qualifiedName)
	
	def Type locateType(QualifiedName qualifiedName)
	
	def Class locateClass(QualifiedName qualifiedName)
	
	def Interface locateInterface(QualifiedName qualifiedName)
	
	def Association locateAssociation(QualifiedName qualifiedName)
	
	def Operation locateOperation(QualifiedName qualifiedName)
	
	def NamedElement locateElement(QualifiedName qualifiedName)
	
	def Model getUMLModel()
}