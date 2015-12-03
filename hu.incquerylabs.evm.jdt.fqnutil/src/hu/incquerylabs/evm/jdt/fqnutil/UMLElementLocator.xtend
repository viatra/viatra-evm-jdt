package hu.incquerylabs.evm.jdt.fqnutil

import org.eclipse.uml2.uml.Element

interface UMLElementLocator {
	def Element locate(String qualifiedName)
}