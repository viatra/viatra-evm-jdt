package com.incquerylabs.evm.jdt.fqnutil

import com.google.common.base.Joiner

class UMLQualifiedName extends QualifiedName {
	
	static val UML_SEPARATOR = "::"
	
	static def QualifiedName create(String qualifiedName) {
		val lastIndexOfSeparator = qualifiedName.lastIndexOf(UML_SEPARATOR)
		if(lastIndexOfSeparator == -1) {
			return new UMLQualifiedName(qualifiedName, null) 
		} else {
			return new UMLQualifiedName(qualifiedName.substring(lastIndexOfSeparator + UML_SEPARATOR.length), create(qualifiedName.substring(0, lastIndexOfSeparator)))
		}
	}
	
	static def QualifiedName create(QualifiedName qualifiedName) {
		create(Joiner::on(UML_SEPARATOR).join(qualifiedName))
	}
	
	protected new(String qualifiedName, QualifiedName parent) {
		super(qualifiedName, parent)
	}
	
	override getSeparator() {
		UML_SEPARATOR
	}
	
}