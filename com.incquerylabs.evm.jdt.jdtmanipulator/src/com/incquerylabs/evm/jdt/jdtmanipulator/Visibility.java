package com.incquerylabs.evm.jdt.jdtmanipulator;

import org.eclipse.jdt.core.dom.Modifier.ModifierKeyword;

public enum Visibility {
	PUBLIC(ModifierKeyword.PUBLIC_KEYWORD),
	PACKAGE(null),
	PROTECTED(ModifierKeyword.PROTECTED_KEYWORD),
	PRIVAT(ModifierKeyword.PRIVATE_KEYWORD);
	
	private ModifierKeyword modifier;
	
	Visibility(ModifierKeyword modifier) {
		this.modifier = modifier;
	}

	public ModifierKeyword getKeyword() {
		return modifier;
	}
}
