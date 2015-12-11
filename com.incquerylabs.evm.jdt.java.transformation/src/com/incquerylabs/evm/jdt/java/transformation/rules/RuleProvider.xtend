package com.incquerylabs.evm.jdt.java.transformation.rules

import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.eclipse.incquery.runtime.evm.specific.resolver.InvertedDisappearancePriorityConflictResolver
import org.eclipse.uml2.uml.Element
import org.eclipse.viatra.emf.runtime.rules.eventdriven.EventDrivenTransformationRule
import org.eclipse.viatra.emf.runtime.rules.eventdriven.EventDrivenTransformationRuleFactory
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.EventDrivenTransformation.EventDrivenTransformationBuilder
import org.eclipse.xtend.lib.annotations.Data

abstract class RuleProvider {
	
	val rules = <PrioritizedRule>newArrayList
	protected val ruleFactory = new EventDrivenTransformationRuleFactory
	
	abstract def void initialize(JDTManipulator manipulator, Map<Element, String> elementNameRegistry)
	
	protected def addRule(EventDrivenTransformationRule<?, ?> rule, int priority) {
		rules.add(new PrioritizedRule(rule, priority))
	}
	
	final def void registerRules(InvertedDisappearancePriorityConflictResolver resolver) {
		rules.forEach[resolver.setPriority(rule.ruleSpecification, priority)]
	}
	
	final def void addRules(EventDrivenTransformationBuilder builder) {
		rules.forEach[builder.addRule(rule)]
	}	
}

@Data
class PrioritizedRule {
	EventDrivenTransformationRule<?, ?> rule
	int priority
}