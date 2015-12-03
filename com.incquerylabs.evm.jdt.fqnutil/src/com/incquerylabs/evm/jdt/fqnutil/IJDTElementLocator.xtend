package com.incquerylabs.evm.jdt.fqnutil

import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.dom.ASTNode

interface IJDTElementLocator {
	def IJavaElement locateJavaElement(QualifiedName qualifiedName)
	
	def ASTNode locateASTNode(QualifiedName qualifiedName)
}