package hu.incquerylabs.evm.jdt.fqnutil

import org.eclipse.jdt.core.IJavaElement

interface JDTElementLocator {
	def IJavaElement locate(String qualifiedName)
}