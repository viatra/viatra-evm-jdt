package hu.incquerylabs.evm.jdt.fqnutil

class UMLQualifiedName extends QualifiedName {
	
	static val UML_SEPARATOR = "::"
	
	static def QualifiedName create(String qualifiedName) {
		val lastIndexOfSeparator = qualifiedName.lastIndexOf(UML_SEPARATOR)
		if(lastIndexOfSeparator == -1) {
			return new UMLQualifiedName(qualifiedName, null) 
		} else {
			return new UMLQualifiedName(qualifiedName, create(qualifiedName.substring(lastIndexOfSeparator + UML_SEPARATOR.length)))
		}
	}
	
	protected new(String qualifiedName, QualifiedName parent) {
		super(qualifiedName, parent)
	}
	
	override getSeparator() {
		UML_SEPARATOR
	}
	
}