package com.incquerylabs.evm.jdt.wrappers

import com.incquerylabs.evm.jdt.fqnutil.JDTInternalQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import java.util.Set
import org.eclipse.jdt.internal.core.builder.ReferenceCollection
import org.apache.log4j.Logger

class JDTReferenceStorage implements ReferenceStorage{
	extension val Logger logger
	Set<QualifiedName> qualifiedNameReferences
	Set<String> simpleNameReferences
	Set<String> rootReferences
	
	new(ReferenceCollection referenceCollection) {
		this.logger = Logger.getLogger(this.class)
		
		if(referenceCollection == null) {
			throw new IllegalArgumentException("Reference collection cannot be null")
		}
		try {
			val qualifiedNameReferencesField = referenceCollection.class.getDeclaredField("qualifiedNameReferences")
			qualifiedNameReferencesField.accessible = true
			val referredQualifiedNames = qualifiedNameReferencesField.get(referenceCollection) as char[][][]
			this.qualifiedNameReferences = referredQualifiedNames.map[fqn | JDTInternalQualifiedName::create(fqn)].toSet
		} catch(NoSuchFieldException e) {
			error('''Failed to get qualified name references from JDT build state''', e)
			this.qualifiedNameReferences = #{}
		}
		try {
			val simpleNameReferencesField = referenceCollection.class.getDeclaredField("simpleNameReferences")
			simpleNameReferencesField.accessible = true
			val referredSimpleNames = simpleNameReferencesField.get(referenceCollection) as char[][]
			this.simpleNameReferences = referredSimpleNames.map[name | new String(name)].toSet
		} catch(NoSuchFieldException e) {
			error('''Failed to get simple name references from JDT build state''', e)
			this.simpleNameReferences = #{}
		}
		
		try {
			val rootReferencesField = referenceCollection.class.getDeclaredField("rootReferences")
			rootReferencesField.accessible = true
			val referredRootNames = rootReferencesField.get(referenceCollection) as char[][]
			this.rootReferences = referredRootNames.map[name | new String(name)].toSet
		} catch(NoSuchFieldException e) {
			error('''Failed to get root references from JDT build state''', e)
			this.rootReferences = #{}
		}
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
