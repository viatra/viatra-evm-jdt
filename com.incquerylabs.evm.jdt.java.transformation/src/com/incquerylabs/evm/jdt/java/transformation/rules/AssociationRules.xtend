package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.java.transformation.queries.util.AssociationOfClassQuerySpecification
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.eclipse.incquery.runtime.evm.specific.Lifecycles
import org.eclipse.incquery.runtime.evm.specific.event.IncQueryActivationStateEnum
import org.eclipse.uml2.uml.Element

import static extension com.incquerylabs.evm.jdt.java.transformation.util.QualifiedNameUtil.*

class AssociationRules extends RuleProvider{
	
	override initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry) {
		addRule(ruleFactory.createRule.precondition(AssociationOfClassQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				val containingClassQN = it.srcEnd.type.qualifiedName.toJDTQN
				val fieldName = it.trgEnd.name
				val typeQN = it.trgEnd.type.qualifiedName.toJDTQN
				manipulator.createField(containingClassQN, fieldName, typeQN)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].action(IncQueryActivationStateEnum.UPDATED) [
				val fieldName = elementNameRegistry.get(it.trgEnd)
				manipulator.updateField((it.srcEnd.type.qualifiedName + "::" + fieldName).toJDTQN, it.trgEnd.type.qualifiedName.toJDTQN, it.trgEnd.name)
				elementNameRegistry.put(it.trgEnd, it.trgEnd.name)
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				val fieldName = it.trgEnd.name
				// TODO: if a type gets deleted and an association points at it, this event gets triggered and the it.srcEnd.type will be null -> not so good behavior
				val fieldQN = (it.srcEnd.type.qualifiedName + "::" + fieldName).toJDTQN 
				manipulator.deleteField(fieldQN)
				elementNameRegistry.remove(it.trgEnd.name)
			].addLifeCycle(Lifecycles::getDefault(true, true)).build, 1)
	}
	
}