package com.incquerylabs.evm.jdt.umlmanipulator

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName

interface IUMLManipulator {
	def void createClass(QualifiedName fqn)
	def void updateClass(QualifiedName fqn)
	def void deleteClass(QualifiedName fqn)
	def void createAssociation(QualifiedName fqn)
	def void updateAssociation(QualifiedName fqn)
	def void deleteAssociation(QualifiedName fqn)
}