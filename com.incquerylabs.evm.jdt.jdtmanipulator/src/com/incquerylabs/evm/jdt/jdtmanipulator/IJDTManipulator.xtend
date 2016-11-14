package com.incquerylabs.evm.jdt.jdtmanipulator

import org.eclipse.jdt.core.IField
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IType
import org.eclipse.viatra.integration.evm.jdt.util.QualifiedName

interface IJDTManipulator {

	def IPackageFragment createPackage(QualifiedName qualifiedName)
	def IType createClass(QualifiedName qualifiedName)
	def IField createField(QualifiedName containerName, String fieldName, QualifiedName type)
	def void createMethod(QualifiedName qualifiedName)
	
	def void deletePackage(QualifiedName qualifiedName)
	def void deleteClass(QualifiedName qualifiedName)
	def void deleteField(QualifiedName qualifiedName)
	def void deleteMethod(QualifiedName qualifiedName)
	
	def boolean updatePackage(QualifiedName oldQualifiedName, QualifiedName newQualifiedName)
	def boolean updateClass(QualifiedName oldQualifiedName, String name)
	def boolean updateField(QualifiedName oldQualifiedName, QualifiedName type, String name)
	def boolean changeMethodName(QualifiedName oldQualifiedName, String name)
}