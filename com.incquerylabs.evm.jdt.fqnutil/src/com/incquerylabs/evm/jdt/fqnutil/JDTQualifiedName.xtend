package com.incquerylabs.evm.jdt.fqnutil

import com.google.common.base.Joiner

class JDTQualifiedName extends QualifiedName {
	
	static val JDT_SEPARATOR = "."
	
	static def QualifiedName create(String qualifiedName) {
		val lastIndexOfSeparator = qualifiedName.lastIndexOf(JDT_SEPARATOR)
		if(lastIndexOfSeparator == -1) {
			return new JDTQualifiedName(qualifiedName, null) 
		} else {
			return new JDTQualifiedName(qualifiedName.substring(lastIndexOfSeparator + JDT_SEPARATOR.length), create(qualifiedName.substring(0, lastIndexOfSeparator)))
		}
	}
	
	static def QualifiedName create(QualifiedName qualifiedName) {
		create(Joiner::on(JDT_SEPARATOR).join(qualifiedName.toList.reverse))
	}
	
	protected new(String qualifiedName, QualifiedName parent) {
		super(qualifiedName, parent)
	}
	
	override getSeparator() {
		JDT_SEPARATOR
	}
	
}