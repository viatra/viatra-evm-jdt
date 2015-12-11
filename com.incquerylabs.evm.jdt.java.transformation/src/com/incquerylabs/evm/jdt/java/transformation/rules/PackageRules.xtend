package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.java.transformation.queries.util.LeafPackageQuerySpecification
import com.incquerylabs.evm.jdt.java.transformation.queries.util.PackageInPackageQuerySpecification
import com.incquerylabs.evm.jdt.java.transformation.queries.util.UmlPackageQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.specific.Lifecycles
import org.eclipse.incquery.runtime.evm.specific.event.IncQueryActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*

class PackageRules extends RuleProvider {
	
	extension val Logger logger = Logger.getLogger(this.class) => [
		level = Level.DEBUG
	]
	
	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		// only handle leaf packages, as otherwise the order they appear could be wrong in some situations
		addRule(ruleFactory.createRule.precondition(LeafPackageQuerySpecification::instance)
			.action(IncQueryActivationStateEnum::APPEARED) [
				debug('''Package appeared: <«it.umlPackage.qualifiedName»>''')
				manipulator.createPackage(it.umlPackage.qualifiedName.toJDTQN)
			].action(IncQueryActivationStateEnum::UPDATED) [
				val packageName = elementNameRegistry.get(it.umlPackage)
				val qualifiedName = (it.umlPackage.namespace.qualifiedName + "::" + packageName)
				debug('''Package updated: <«qualifiedName»>''')
				manipulator.updatePackage(qualifiedName.toJDTQN, it.umlPackage.qualifiedName.toJDTQN)				
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 0
		)
		
		addRule(ruleFactory.createRule.precondition(UmlPackageQuerySpecification::instance)
			.action(IncQueryActivationStateEnum::APPEARED) [
				elementNameRegistry.put(it.umlPackage, it.umlPackage.name)
			].action(IncQueryActivationStateEnum::UPDATED) [
				val packageName = elementNameRegistry.get(it.umlPackage)
				val qualifiedName = (it.umlPackage.namespace.qualifiedName + "::" + packageName)
				debug('''Package updated: <«qualifiedName»>''')
				manipulator.updatePackage(qualifiedName.toJDTQN, it.umlPackage.qualifiedName.toJDTQN)				
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 0
		)
		
		addRule(ruleFactory.createRule.precondition(PackageInPackageQuerySpecification::instance)
			// TODO: use proper lifecycle instead of this hack
			.action(IncQueryActivationStateEnum::APPEARED) [] 
			.action(IncQueryActivationStateEnum::DISAPPEARED) [
				debug('''Package disappeared: <«it.child.name»> in <«it.parent.qualifiedName»>''')
				val packageQualifiedName = it.parent.qualifiedName + "::" + it.child.name
				manipulator.deletePackage(packageQualifiedName.toJDTQN)
			].addLifeCycle(Lifecycles::getDefault(false, true)).build, 1
		)
	}
	
}