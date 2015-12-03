package com.incquerylabs.evm.jdt.fqnutil

import java.util.Optional

abstract class QualifiedName {
	
	protected val String name
	protected val Optional<? extends QualifiedName> parent
	
	protected new(String qualifiedName, QualifiedName parent) {
		this.name = qualifiedName
		this.parent = Optional::ofNullable(parent)
	}
	
	def getName() {
		return name
	}
	
	def getParent() {
		return parent
	}

	override toString() {
		val builder = new StringBuilder()
		parent.ifPresent[
			builder.append(it.toString).append(separator)
		]
		return builder.append(name).toString		 
	}
	
	abstract def String getSeparator()
}