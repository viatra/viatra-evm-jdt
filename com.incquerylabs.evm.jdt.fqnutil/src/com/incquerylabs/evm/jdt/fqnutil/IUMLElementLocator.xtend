package com.incquerylabs.evm.jdt.fqnutil

import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package

interface IUMLElementLocator {
	def Package locatePackage(QualifiedName qualifiedName)
	
	def Class locateClass(QualifiedName qualifiedName)
	
	def Association locateAssociation(QualifiedName qualifiedName)
	
	def Operation locateOperation(QualifiedName qualifiedName)
	
	def Model getUMLModel()
}