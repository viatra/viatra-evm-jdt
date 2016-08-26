package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.common.queries.util.LeafPackageQuerySpecification
import com.incquerylabs.evm.jdt.common.queries.util.PackageInPackageQuerySpecification
import com.incquerylabs.evm.jdt.common.queries.util.UmlPackageQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.viatra.transformation.evm.specific.Lifecycles
import org.eclipse.viatra.transformation.evm.specific.crud.CRUDActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*

class PackageRules extends RuleProvider {
	
	extension val Logger logger = Logger.getLogger(this.class) => [
		level = Level.DEBUG
	]
	
	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		// only handle leaf packages, as otherwise the order they appear could be wrong in some situations
		addRule(ruleFactory.createRule.precondition(LeafPackageQuerySpecification::instance)
			.action(CRUDActivationStateEnum::CREATED) [
				debug('''Leaf package appeared: <«it.umlPackage.qualifiedName»>''')
				if(synchronizationEnabled){
					manipulator.createPackage(it.umlPackage.qualifiedName.toJDTQN)
				}
			].action(CRUDActivationStateEnum::UPDATED) [
				val packageName = elementNameRegistry.get(it.umlPackage)
				val qualifiedName = (it.umlPackage.namespace.qualifiedName + "::" + packageName)
				debug('''Leaf package updated: <«qualifiedName»>''')
				if(synchronizationEnabled){
					manipulator.updatePackage(qualifiedName.toJDTQN, it.umlPackage.qualifiedName.toJDTQN)
				}
				elementNameRegistry.put(it.umlPackage, it.umlPackage.name)
			].addLifeCycle(Lifecycles::getDefault(true, false)).build, 0
		)
		
		addRule(ruleFactory.createRule.precondition(UmlPackageQuerySpecification::instance)
			.action(CRUDActivationStateEnum::CREATED) [
				elementNameRegistry.put(it.umlPackage, it.umlPackage.name)
			].action(CRUDActivationStateEnum::UPDATED) [
				val packageName = elementNameRegistry.get(it.umlPackage)
				val qualifiedName = (it.umlPackage.namespace.qualifiedName + "::" + packageName)
				debug('''Package updated: <«qualifiedName»>''')
				if(synchronizationEnabled) {
					manipulator.updatePackage(qualifiedName.toJDTQN, it.umlPackage.qualifiedName.toJDTQN)
				}
				elementNameRegistry.put(it.umlPackage, it.umlPackage.name)
			].addLifeCycle(Lifecycles::getDefault(true, false)).build, 0
		)
		
		addRule(ruleFactory.createRule.precondition(PackageInPackageQuerySpecification::instance)
			// TODO: use proper lifecycle instead of this hack
			.action(CRUDActivationStateEnum::CREATED) [] 
			.action(CRUDActivationStateEnum::CREATED) [
				debug('''Child package disappeared: <«it.child.name»> in <«it.parent.qualifiedName»>''')
				val packageQualifiedName = it.parent.qualifiedName + "::" + it.child.name
				if(synchronizationEnabled){
					manipulator.deletePackage(packageQualifiedName.toJDTQN)
				}
				elementNameRegistry.remove(it.child)
			].addLifeCycle(Lifecycles::getDefault(false, true)).build, 1
		)
	}
	
}