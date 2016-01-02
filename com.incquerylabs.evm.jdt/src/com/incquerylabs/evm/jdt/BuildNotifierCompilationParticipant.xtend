package com.incquerylabs.evm.jdt

import com.incquerylabs.evm.jdt.fqnutil.JDTInternalQualifiedName
import java.lang.reflect.Field
import java.util.List
import java.util.Map
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.compiler.BuildContext
import org.eclipse.jdt.core.compiler.CompilationParticipant
import org.eclipse.jdt.internal.core.JavaModelManager
import org.eclipse.jdt.internal.core.builder.ReferenceCollection
import org.eclipse.jdt.internal.core.builder.State
import org.eclipse.jdt.internal.core.builder.StringSet
import org.eclipse.core.runtime.Path

class BuildNotifierCompilationParticipant extends CompilationParticipant {
	extension val Logger logger = Logger.getLogger(this.class)
	
	new() {
		logger.level = Level.DEBUG
	}
	
	override isActive(IJavaProject project) {
		return true
	}
	
	override buildFinished(IJavaProject project) {
		val iproject = project.project
		val lastState = JavaModelManager.getJavaModelManager().getLastBuiltState(iproject, new NullProgressMonitor()) as State
		if(lastState != null) {
			val references = getReferences(lastState)
			references.forEach[file, reference|
				info('''File «file» contains references to «reference»''')
			]
			val changedTypes = lastState.structurallyChangedTypes
			debug('''Structurally changed types are «FOR type:changedTypes SEPARATOR ", "»«type»«ENDFOR»''')
			val affectedFiles = lastState.getAffectedCompilationUnitsInProject
			debug('''Affected files are «FOR file : affectedFiles SEPARATOR ", "»«file»«ENDFOR»''')
			val compilationUnits = affectedFiles.map[fqn | project.findElement(new Path(fqn.toString))]
			debug('''Affected compilation units are «FOR cu : compilationUnits SEPARATOR ", "»«cu»«ENDFOR»''')
		}
		
		debug('''Build of «project.elementName» has finished''')
	}
	
	override aboutToBuild(IJavaProject project) {
		trace('''About to build «project.elementName»''')
		super.aboutToBuild(project)
	}
	
	override buildStarting(BuildContext[] files, boolean isBatch) {
		trace('''Build starting for [«FOR file:files SEPARATOR ", "»«file»«ENDFOR»]''')
		super.buildStarting(files, isBatch)
	}
	
	override cleanStarting(IJavaProject project) {
		trace('''Clean starting on «project.elementName»''')
		super.cleanStarting(project)
	}
	
	private def Map<String, ReferenceStorage> getReferences(State state) {
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
	
	private def getAffectedCompilationUnitsInProject(State state) {
		val changedTypes = state.structurallyChangedTypes
		val references = getReferences(state)
		val affectedCompilationUnits = references.filter[referer, referenceStorage|
			changedTypes.exists[ nameString |
				val fqn = JDTInternalQualifiedName::create(nameString)
				referenceStorage.qualifiedNameReferences.contains(fqn)
			]
		].keySet.map[
			val fullPath = JDTInternalQualifiedName::create(it)
			val pathWithoutSrcSegment = fullPath.iterator.toList.reverse.tail.join('/')
			JDTInternalQualifiedName::create(pathWithoutSrcSegment)
		]
		return affectedCompilationUnits
	}
	
	private def List<String> getStructurallyChangedTypes(State state) {
		val Field field = state.class.getDeclaredField("structurallyChangedTypes")
		field.accessible = true
		val structurallyChangedTypes = field.get(state) as StringSet
		if(structurallyChangedTypes == null) {
			return #[]
		}
		return structurallyChangedTypes.toList
	}
	
	private def List<String> toList(StringSet stringSet) {
		stringSet.values.filter[it!=null].toList
	}
}
