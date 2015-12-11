package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.java.transformation.queries.util.LeafPackageQuerySpecification
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
				debug('''Package appeared: <«it.qualifiedName»>''')
				manipulator.createPackage(it.qualifiedName.toJDTQN)
			].action(IncQueryActivationStateEnum::UPDATED) [
				debug('''Package updated: <«it.qualifiedName»>''')
			].action(IncQueryActivationStateEnum::DISAPPEARED) [
				debug('''Package disappeared: <«it.qualifiedName»>''')
				manipulator.deletePackage(it.qualifiedName.toJDTQN)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 0
		)
	}
	
}