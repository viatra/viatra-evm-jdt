package hu.incquerylabs.evm.jdt.fqnutil

interface IQualifiedNameTransformer {
	
	def String toUmlQualifiedName(String jdtQualifiedName)
	def String toJdtQualifiedName(String umlQualifiedName)
	
}