package com.incquerylabs.evm.jdt.java.transformation.util

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName

class QualifiedNameUtil {

	static def toJDTQN(String umlQNString) {
		JDTQualifiedName::create(UMLQualifiedName::create(umlQNString))
	}
	
}