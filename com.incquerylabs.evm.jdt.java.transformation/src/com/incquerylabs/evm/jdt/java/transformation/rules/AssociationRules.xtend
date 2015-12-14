package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.common.queries.util.AssociationOfClassQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.specific.Lifecycles
import org.eclipse.incquery.runtime.evm.specific.event.IncQueryActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*
import com.incquerylabs.evm.jdt.common.queries.util.UmlAssociationQuerySpecification

class AssociationRules extends RuleProvider {

	extension val Logger logger = Logger.getLogger(this.class) => [
		level = Level.DEBUG
	]

	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		addRule(ruleFactory.createRule.precondition(UmlAssociationQuerySpecification::instance)
			.action(IncQueryActivationStateEnum::APPEARED) [
				debug('''Association appeared: <«it.association.qualifiedName»> from:<«it.srcEnd.type.qualifiedName»> to:<«it.trgEnd.type?.qualifiedName»>''')
				val containingClassQN = it.srcEnd.type.qualifiedName.toJDTQN
				val fieldName = it.trgEnd.name
				val typeQN = it.trgEnd.type.qualifiedName.toJDTQN
				manipulator.createField(containingClassQN, fieldName, typeQN)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].action(IncQueryActivationStateEnum::UPDATED) [
				debug('''Association updated: <«it.association.qualifiedName»> from:<«it.srcEnd.type.qualifiedName»> to:<«it.trgEnd.type?.qualifiedName»>''')
				val fieldName = elementNameRegistry.get(it.trgEnd)
				manipulator.updateField((it.srcEnd.type.qualifiedName + "::" + fieldName).toJDTQN,
					it.trgEnd.type.qualifiedName.toJDTQN, it.trgEnd.name)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].addLifeCycle(Lifecycles::getDefault(true, false)).build, 4
		)
		
		addRule(
			ruleFactory.createRule.precondition(AssociationOfClassQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				debug('''Association appeared: <«it.association.qualifiedName»> from:<«it.srcEnd.type.qualifiedName»> to:<«it.trgEnd.type?.qualifiedName»>''')
				val containingClassQN = it.srcEnd.type.qualifiedName.toJDTQN
				val fieldName = it.trgEnd.name
				val typeQN = it.trgEnd.type.qualifiedName.toJDTQN
				manipulator.createField(containingClassQN, fieldName, typeQN)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			]
			.action(IncQueryActivationStateEnum.DISAPPEARED) [
				debug('''Association disappeared: <«it.association.qualifiedName»> from:<«it.srcQn»> to:<«it.trgEnd?.type.qualifiedName»>''')
				val fieldName = it.trgEnd.name
				val fieldQN = (it.srcQn + "::" + fieldName).toJDTQN
				manipulator.deleteField(fieldQN)
				elementNameRegistry.remove(it.trgEnd.name)
			].addLifeCycle(Lifecycles::getDefault(false, true)).build, 5)
	}

}