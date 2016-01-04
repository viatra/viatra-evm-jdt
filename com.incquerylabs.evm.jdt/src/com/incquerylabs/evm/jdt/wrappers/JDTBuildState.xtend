package com.incquerylabs.evm.jdt.wrappers

import com.incquerylabs.evm.jdt.fqnutil.JDTInternalQualifiedName
import java.lang.reflect.Field
import java.util.List
import java.util.Map
import org.eclipse.jdt.internal.core.builder.ReferenceCollection
import org.eclipse.jdt.internal.core.builder.State
import org.eclipse.jdt.internal.core.builder.StringSet

class JDTBuildState implements BuildState {
	val State state
	
	new(State state) {
		this.state = state
	}
	
	override getStructurallyChangedTypes() {
		val Field field = state.class.getDeclaredField("structurallyChangedTypes")
		field.accessible = true
		val structurallyChangedTypes = field.get(state) as StringSet
		if(structurallyChangedTypes == null) {
			return #[]
		}
		return structurallyChangedTypes.toList
	}
	
	override Map<String, ReferenceStorage> getReferences() {
		val referencesLookup = state.references
		val keySet = referencesLookup.keyTable
		val valueSet = referencesLookup.valueTable
		
		val references = <String, ReferenceStorage>newHashMap()
		for(i : 0..<keySet.length) {
			val currentKey = keySet.get(i) as String
			val currentValue = valueSet.get(i) as ReferenceCollection
			if(currentKey != null && currentValue != null) {
				val referenceStorage = new JDTReferenceStorage(currentValue)
				references.put(currentKey, referenceStorage)
			}
		}
		return references
	}
	
	override getAffectedCompilationUnitsInProject() {
		val changedTypes = this.structurallyChangedTypes
		val references = this.references
		val affectedCompilationUnits = references.filter[referer, referenceStorage|
			changedTypes.exists[ nameString |
				val fqn = JDTInternalQualifiedName::create(nameString)
				val containedAsQualifiedName = referenceStorage.qualifiedNameReferences.contains(fqn)
				val containedAsSimpleName = referenceStorage.simpleNameReferences.contains(fqn.name)
				return containedAsQualifiedName || containedAsSimpleName
			]
		].keySet.map[
			val fullPath = JDTInternalQualifiedName::create(it)
			val pathWithoutSrcSegment = fullPath.iterator.toList.reverse.tail.join('/')
			JDTInternalQualifiedName::create(pathWithoutSrcSegment)
		]
		return affectedCompilationUnits
	}
	
	private def List<String> toList(StringSet stringSet) {
		stringSet.values.filter[it!=null].toList
	}
}
