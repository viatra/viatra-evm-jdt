package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.common.queries.util.UmlClassInModelQuerySpecification
import com.incquerylabs.evm.jdt.common.queries.util.UmlClassInPackageQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.viatra.transformation.evm.specific.Lifecycles
import org.eclipse.viatra.transformation.evm.specific.crud.CRUDActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*

class ClassRules extends RuleProvider {

	extension val Logger logger = Logger.getLogger(this.class) => [
		level = Level.DEBUG
	]

	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
//		addRule(ruleFactory.createRule.precondition(UmlClassQuerySpecification::instance)
//			.action(CRUDActivationStateEnum::APPEARED) [
//				debug('''Class appeared: <«it.umlClass.qualifiedName»>''')
//				val qualifiedName = it.umlClass.qualifiedName.toJDTQN
//				//manipulator.createClass(qualifiedName)
//				elementNameRegistry.put(it.umlClass, it.umlClass.name)
//			].action(CRUDActivationStateEnum::UPDATED) []
//			.addLifeCycle(Lifecycles::getDefault(true, false)).build, 2
//		)

		addRule(ruleFactory.createRule.precondition(UmlClassInModelQuerySpecification::instance)
			// TODO: use proper lifecycle instead of this hack
			.action(CRUDActivationStateEnum::CREATED)[
				debug('''Class in package appeared: <«it.umlClass.qualifiedName»>''')
				val qualifiedName = it.umlClass.qualifiedName.toJDTQN
				if(synchronizationEnabled){
					manipulator.createClass(qualifiedName)
				}
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			]
			.action(CRUDActivationStateEnum::UPDATED) [
				val clazzName = elementNameRegistry.get(it.umlClass)
				val qualifiedName = (it.umlClass.package.qualifiedName + "::" + clazzName)
				debug('''Class in model updated: <«qualifiedName»>''')
				if(synchronizationEnabled){
					manipulator.updateClass(qualifiedName.toJDTQN, it.umlClass.name)
				}
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(CRUDActivationStateEnum::DELETED) [
				val qualifiedName = (it.model.qualifiedName + "::" + it.umlClass.name).toJDTQN
				debug('''Class in model disappeared: <«qualifiedName»>''')
				if(synchronizationEnabled){
					manipulator.deleteClass(qualifiedName)
				}
				elementNameRegistry.remove(it.umlClass.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 3
		)

		addRule(ruleFactory.createRule.precondition(UmlClassInPackageQuerySpecification::instance)
			// TODO: use proper lifecycle instead of this hack
			.action(CRUDActivationStateEnum::CREATED)[
				debug('''Class in package appeared: <«it.umlClass.qualifiedName»>''')
				val qualifiedName = it.umlClass.qualifiedName.toJDTQN
				if(synchronizationEnabled){
					manipulator.createClass(qualifiedName)
				}
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			]
			.action(CRUDActivationStateEnum::UPDATED) [
				val clazzName = elementNameRegistry.get(it.umlClass)
				val qualifiedName = (it.umlClass.package.qualifiedName + "::" + clazzName)
				debug('''Class in package updated: <«qualifiedName»>''')
				if(synchronizationEnabled){
					manipulator.updateClass(qualifiedName.toJDTQN, it.umlClass.name)
				}
				elementNameRegistry.put(it.umlClass, it.umlClass.name)
			].action(CRUDActivationStateEnum::DELETED) [
				debug('''Class in package disappeared: <«it.umlClass.qualifiedName»>''')
				val qualifiedName = (it.umlPackage.qualifiedName + "::" + it.umlClass.name).toJDTQN
				if(synchronizationEnabled && it.umlPackage.eContainer != null){
					manipulator.deleteClass(qualifiedName)
				}
				elementNameRegistry.remove(it.umlClass.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 3
		)
	}
}
