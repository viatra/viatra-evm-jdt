package com.incquerylabs.evm.jdt.umlmanipulator

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName

interface IUMLManipulator {
	def void createClass(QualifiedName fqn)
	def void updateName(QualifiedName fqn)
	def void deleteClass(QualifiedName fqn)
	def void deleteClassAndReferences(QualifiedName fqn)
	def void createAssociation(QualifiedName fqn, QualifiedName typeQualifiedName)
	def void deleteAssociation(QualifiedName fqn)
	def void updateType(QualifiedName fqn, QualifiedName typeQualifiedName)
	def void save()
}