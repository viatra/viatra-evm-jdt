package com.incquerylabs.evm.jdt.fqnutil

import org.eclipse.jdt.core.IField
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IMethod
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.core.IType
import org.eclipse.viatra.integration.evm.jdt.util.QualifiedName

interface IJDTElementLocator {
	def IPackageFragmentRoot locateSourceRoot()
	
	def IPackageFragment locatePackage(QualifiedName qualifiedName)
	
	def IType locateClass(QualifiedName qualifiedName)
	
	def IField locateFieldNode(QualifiedName qualifiedName)
	
	def IMethod locateMethodNode(QualifiedName qualifiedName)
	
	def IJavaProject getJavaProject()
}