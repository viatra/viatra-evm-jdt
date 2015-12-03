package com.incquerylabs.evm.jdt.fqnutil

interface IQualifiedNameTransformer {
	
	def QualifiedName toUmlQualifiedName(QualifiedName jdtQualifiedName)
	def QualifiedName toJdtQualifiedName(QualifiedName umlQualifiedName)
	
}