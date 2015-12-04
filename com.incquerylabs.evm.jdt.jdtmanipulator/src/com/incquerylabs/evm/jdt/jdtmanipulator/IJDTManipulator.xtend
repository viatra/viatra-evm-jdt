package com.incquerylabs.evm.jdt.jdtmanipulator

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName

interface IJDTManipulator {

	def void createPackage(QualifiedName qualifiedName)
	def void createClass(QualifiedName qualifiedName)
	def void createField(QualifiedName qualifiedName, QualifiedName type)
	def void createMethod(QualifiedName qualifiedName)
	
	def void deletePackage(QualifiedName qualifiedName)
	def void deleteClass(QualifiedName qualifiedName)
	def void deleteField(QualifiedName qualifiedName)
	def void deleteMethod(QualifiedName qualifiedName)
	
	def void changePackageName(QualifiedName oldQualifiedName, String name)
	def void changeClassName(QualifiedName oldQualifiedName, String name)
	def void changeFieldName(QualifiedName oldQualifiedName, String name)
	def void changeMethodName(QualifiedName oldQualifiedName, String name)
	
	def void changeFieldVisibility(QualifiedName qualifiedName, Visibility visibility)
	def void changeMethodVisibility(QualifiedName qualifiedName, Visibility visibility)
	
	def void changeClassAbstract(QualifiedName qualifiedName, boolean isAbstract)
	def void changeMethodAbstract(QualifiedName qualifiedName, boolean isAbstract)
	
	def void changeFieldFinal(QualifiedName qualifiedName, boolean isFinal)
	def void changeMethodFinal(QualifiedName qualifiedName, boolean isFinal)
}