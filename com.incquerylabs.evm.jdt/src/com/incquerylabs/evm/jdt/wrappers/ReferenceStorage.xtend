package com.incquerylabs.evm.jdt.wrappers

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import java.util.Set

interface ReferenceStorage {
	def Set<QualifiedName> getQualifiedNameReferences()
	def Set<String> getSimpleNameReferences()
	def Set<String> getRootReferences()
}