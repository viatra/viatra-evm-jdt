package com.incquerylabs.evm.jdt.wrappers

import com.incquerylabs.evm.jdt.fqnutil.JDTInternalQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import java.util.Set
import org.eclipse.jdt.internal.core.builder.ReferenceCollection

class JDTReferenceStorage implements ReferenceStorage{
	val Set<QualifiedName> qualifiedNameReferences
	val Set<String> simpleNameReferences
	val Set<String> rootReferences
	
	new(ReferenceCollection referenceCollection) {
		if(referenceCollection == null) {
			throw new IllegalArgumentException("Reference collection cannot be null")
		}
		
		val qualifiedNameReferencesField = referenceCollection.class.getDeclaredField("qualifiedNameReferences")
		qualifiedNameReferencesField.accessible = true
		val referredQualifiedNames = qualifiedNameReferencesField.get(referenceCollection) as char[][][]
		this.qualifiedNameReferences = referredQualifiedNames.map[fqn | JDTInternalQualifiedName::create(fqn)].toSet
		
		val simpleNameReferencesField = referenceCollection.class.getDeclaredField("simpleNameReferences")
		simpleNameReferencesField.accessible = true
		val referredSimpleNames = simpleNameReferencesField.get(referenceCollection) as char[][]
		this.simpleNameReferences = referredSimpleNames.map[name | new String(name)].toSet
		
		val rootReferencesField = referenceCollection.class.getDeclaredField("rootReferences")
		rootReferencesField.accessible = true
		val referredRootNames = rootReferencesField.get(referenceCollection) as char[][]
		this.rootReferences = referredRootNames.map[name | new String(name)].toSet
	}
	
	override getQualifiedNameReferences() {
		qualifiedNameReferences
	}
	
	override getRootReferences() {
		rootReferences
	}
	
	override getSimpleNameReferences() {
		simpleNameReferences
	}
}
