package com.incquerylabs.evm.jdt.jdtmanipulator

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import org.eclipse.jdt.core.IField
import org.eclipse.jdt.core.IType
import org.eclipse.jdt.core.IPackageFragment

interface IJDTManipulator {

	def IPackageFragment createPackage(QualifiedName qualifiedName)
	def IType createClass(QualifiedName qualifiedName)
	def IField createField(QualifiedName containerName, String fieldName, QualifiedName type)
	def void createMethod(QualifiedName qualifiedName)
	
	def void deletePackage(QualifiedName qualifiedName)
	def void deleteClass(QualifiedName qualifiedName)
	def void deleteField(QualifiedName qualifiedName)
	def void deleteMethod(QualifiedName qualifiedName)
	
	def void updatePackage(QualifiedName oldQualifiedName, QualifiedName newQualifiedName)
	def void updateClass(QualifiedName oldQualifiedName, String name)
	def void updateField(QualifiedName oldQualifiedName, QualifiedName type, String name)
	def void changeMethodName(QualifiedName oldQualifiedName, String name)
}