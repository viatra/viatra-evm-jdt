package com.incquerylabs.evm.jdt.wrappers

import java.util.List
import java.util.Map
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName

interface BuildState {
	def List<String> getStructurallyChangedTypes()
	def Map<String, ReferenceStorage> getReferences()
	def Iterable<QualifiedName> getAffectedCompilationUnitsInProject()
}