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

class AssociationRules extends RuleProvider {

	extension val Logger logger = Logger.getLogger(this.class) => [
		level = Level.DEBUG
	]

	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		addRule(
			ruleFactory.createRule.precondition(AssociationOfClassQuerySpecification::instance).action(
				IncQueryActivationStateEnum.APPEARED) [
				debug('''Association appeared: <«it.association.qualifiedName»> from:<«it.srcType.qualifiedName»> to:<«it.trgType.qualifiedName»>''')
				val containingClassQN = it.srcEnd.type.qualifiedName.toJDTQN
				val fieldName = it.trgEnd.name
				val typeQN = it.trgEnd.type.qualifiedName.toJDTQN
				manipulator.createField(containingClassQN, fieldName, typeQN)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].action(IncQueryActivationStateEnum.UPDATED) [
				debug('''Association updated: <«it.association.qualifiedName»> from:<«it.srcType.qualifiedName»> to:<«it.trgType.qualifiedName»>''')
				val fieldName = elementNameRegistry.get(it.trgEnd)
				manipulator.updateField((it.srcEnd.type.qualifiedName + "::" + fieldName).toJDTQN,
					it.trgEnd.type.qualifiedName.toJDTQN, it.trgEnd.name)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				debug('''Association disappeared: <«it.association.qualifiedName»> from:<«it.srcQn»> to:<«it.trgType.qualifiedName»>''')
				val fieldName = it.trgEnd.name
				// TODO: if a type gets deleted and an association points at it, this event gets triggered and the it.srcEnd.type will be null -> not so good behavior
				val fieldQN = (it.srcQn + "::" + fieldName).toJDTQN
				manipulator.deleteField(fieldQN)
				elementNameRegistry.remove(it.trgEnd.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 2)
	}

}