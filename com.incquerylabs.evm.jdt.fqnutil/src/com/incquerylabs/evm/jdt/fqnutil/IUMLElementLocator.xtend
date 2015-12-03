package com.incquerylabs.evm.jdt.fqnutil

import org.eclipse.uml2.uml.Element

interface IUMLElementLocator {
	def Element locate(QualifiedName qualifiedName)
}