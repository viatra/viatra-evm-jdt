package hu.incquerylabs.evm.jdt.fqnutil

class JDTQualifiedName extends QualifiedName {
	
	static val JDT_SEPARATOR = "."
	
	static def QualifiedName create(String qualifiedName) {
		val lastIndexOfSeparator = qualifiedName.lastIndexOf(JDT_SEPARATOR)
		if(lastIndexOfSeparator == -1) {
			return new UMLQualifiedName(qualifiedName, null) 
		} else {
			return new UMLQualifiedName(qualifiedName, create(qualifiedName.substring(lastIndexOfSeparator + JDT_SEPARATOR.length)))
		}
	}
	
	protected new(String qualifiedName, QualifiedName parent) {
		super(qualifiedName, parent)
	}
	
	override getSeparator() {
		JDT_SEPARATOR
	}
	
}