package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.java.transformation.queries.util.UmlClassInModelQuerySpecification
import com.incquerylabs.evm.jdt.java.transformation.queries.util.UmlClassInPackageQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.eclipse.incquery.runtime.evm.specific.Lifecycles
import org.eclipse.incquery.runtime.evm.specific.event.IncQueryActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*

class ClassRules extends RuleProvider {	
	
	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		addRule(ruleFactory.createRule.precondition(UmlClassInModelQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				val qualifiedName = it.umlClass.qualifiedName.toJDTQN
				manipulator.createClass(qualifiedName)
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(IncQueryActivationStateEnum.UPDATED) [
				val clazzName = elementNameRegistry.get(it.umlClass)
				manipulator.updateClass((it.model.qualifiedName + "::" + clazzName).toJDTQN, it.umlClass.name)
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				val qualifiedName = (it.model.qualifiedName + "::" + it.umlClass.name).toJDTQN
				manipulator.deleteClass(qualifiedName)
				elementNameRegistry.remove(it.umlClass.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 0)
			
		addRule(ruleFactory.createRule.precondition(UmlClassInPackageQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				val qualifiedName = it.umlClass.qualifiedName.toJDTQN
				manipulator.createClass(qualifiedName)
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(IncQueryActivationStateEnum.UPDATED) [
				val clazzName = elementNameRegistry.get(it.umlClass)
				manipulator.updateClass((it.umlPackage.qualifiedName + "::" + clazzName).toJDTQN, it.umlClass.name)
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				val qualifiedName = (it.umlPackage.qualifiedName + "::" + it.umlClass.name).toJDTQN
				manipulator.deleteClass(qualifiedName)
				elementNameRegistry.remove(it.umlClass.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 0)
	}
}