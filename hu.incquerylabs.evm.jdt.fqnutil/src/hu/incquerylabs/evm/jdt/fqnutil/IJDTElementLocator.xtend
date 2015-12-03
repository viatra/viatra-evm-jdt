package hu.incquerylabs.evm.jdt.fqnutil

import org.eclipse.jdt.core.IJavaElement

interface IJDTElementLocator {
	def IJavaElement locate(String qualifiedName)
}