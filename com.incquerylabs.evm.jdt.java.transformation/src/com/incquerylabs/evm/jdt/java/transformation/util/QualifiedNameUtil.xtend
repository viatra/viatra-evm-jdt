package com.incquerylabs.evm.jdt.java.transformation.util

import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName

class QualifiedNameUtil {

	static def toJDTQN(String umlQNString) {
		val umlQualifiedName = UMLQualifiedName::create(umlQNString).dropRoot
		return JDTQualifiedName::create(umlQualifiedName)
	}
	
}