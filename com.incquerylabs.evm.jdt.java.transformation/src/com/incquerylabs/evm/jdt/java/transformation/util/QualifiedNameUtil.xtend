package com.incquerylabs.evm.jdt.java.transformation.util

import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import org.eclipse.viatra.integration.evm.jdt.util.JDTQualifiedName

class QualifiedNameUtil {

	static def toJDTQN(String umlQNString) {
		val umlQualifiedName = UMLQualifiedName::create(umlQNString).dropRoot
		return JDTQualifiedName::create(umlQualifiedName)
	}
	
}