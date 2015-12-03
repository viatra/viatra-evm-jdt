package com.incquerylabs.evm.jdt.umlmanipulator;

public enum UMLElementType {
	CLASS("class"),
	OPERATION("operation"),
	ASSOCIATION("association"),
	ATTRIBUTE("attribute");
	
	private final String name;
	UMLElementType(String name) {
		this.name = name;
	}
	
	public final String toString() {
		return this.name;
	}
}
