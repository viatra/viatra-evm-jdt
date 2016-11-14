package com.incquerylabs.evm.jdt.fqnutil.impl

import com.incquerylabs.evm.jdt.fqnutil.IJDTElementLocator
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.viatra.integration.evm.jdt.util.QualifiedName

class JDTElementLocator implements IJDTElementLocator {

	IJavaProject project

	new(IJavaProject project) {
		this.project = project
	}
	
	override locateSourceRoot() {
	}

	override locatePackage(QualifiedName qualifiedName) {
	}
	
	override locateClass(QualifiedName qualifiedName) {
		project.findType(qualifiedName.toString)
	}

	override locateFieldNode(QualifiedName qualifiedName) {
		val type = locateClass(qualifiedName.parent.get)
		type.getField(qualifiedName.name)
	}

	override locateMethodNode(QualifiedName qualifiedName) {
	}

	override getJavaProject() {
		project
	}
}