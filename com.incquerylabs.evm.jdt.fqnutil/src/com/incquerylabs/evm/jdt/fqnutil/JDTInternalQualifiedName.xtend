package com.incquerylabs.evm.jdt.fqnutil

class JDTInternalQualifiedName extends QualifiedName {
	static val JDT_INTERNAL_SEPARATOR = "/"
	
	static def QualifiedName create(String qualifiedName) {
		val lastIndexOfSeparator = qualifiedName.lastIndexOf(JDT_INTERNAL_SEPARATOR)
		if(lastIndexOfSeparator == -1) {
			return new JDTQualifiedName(qualifiedName, null) 
		} else {
			return new JDTQualifiedName(qualifiedName.substring(lastIndexOfSeparator + JDT_INTERNAL_SEPARATOR.length), create(qualifiedName.substring(0, lastIndexOfSeparator)))
		}
	}
	
	static def QualifiedName create(QualifiedName qualifiedName) {
		create(qualifiedName.toList.reverse.join(JDT_INTERNAL_SEPARATOR))
	}
	
	static def QualifiedName create(char[][] qualifiedName) {
		val qualifiedNameString = qualifiedName.map[fragment | new String(fragment)].join(JDT_INTERNAL_SEPARATOR)
		create(qualifiedNameString)
	}
	
	protected new(String qualifiedName, QualifiedName parent) {
		super(qualifiedName, parent)
	}
	
	override getSeparator() {
		JDT_INTERNAL_SEPARATOR
	}
}