package com.incquerylabs.evm.jdt.java.transformation

import com.google.common.base.Preconditions
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.JDTElementLocator
import com.incquerylabs.evm.jdt.java.transformation.queries.UmlQueries
import com.incquerylabs.evm.jdt.java.transformation.queries.util.AssociationOfClassQuerySpecification
import com.incquerylabs.evm.jdt.java.transformation.queries.util.UmlClassQuerySpecification
import com.incquerylabs.evm.jdt.java.transformation.util.PerJobFixedPriorityConflictResolver
import com.incquerylabs.evm.jdt.jdtmanipulator.IJDTManipulator
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import org.eclipse.incquery.runtime.api.GenericPatternGroup
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.incquery.runtime.emf.EMFScope
import org.eclipse.incquery.runtime.evm.api.Scheduler.ISchedulerFactory
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.incquery.runtime.evm.specific.event.IncQueryActivationStateEnum
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.uml2.uml.Model
import org.eclipse.viatra.emf.runtime.rules.eventdriven.EventDrivenTransformationRule
import org.eclipse.viatra.emf.runtime.rules.eventdriven.EventDrivenTransformationRuleFactory
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.EventDrivenTransformation
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.ExecutionSchemaBuilder
import org.eclipse.xtend.lib.annotations.Data

class UMLToJavaTransformation {

	static val umlQueries = UmlQueries::instance
	
	IncQueryEngine engine
	val EventDrivenTransformationRuleFactory ruleFactory = new EventDrivenTransformationRuleFactory 
	ISchedulerFactory schedulerFactory
	EventDrivenTransformation transformation

	JDTManipulator manipulator
	
	boolean initialized = false
	
	
	
	new(IJavaProject project, Model model) {
		manipulator = new JDTManipulator(new JDTElementLocator(project))
		engine = IncQueryEngine::on(new EMFScope(model))	
	}
	
	
	def initialize() {
		Preconditions.checkArgument(engine != null, "Engine cannot be null!")
		if(!initialized) {
			if(schedulerFactory == null) {
				schedulerFactory = Schedulers.getIQEngineSchedulerFactory(engine)
			}			
		}
		
		val queries = GenericPatternGroup::of(umlQueries)
		queries.prepare(engine)
		
		val transformationBuilder = EventDrivenTransformation::forEngine(engine)
		
		val rules = initRules(manipulator)
		val fixedPriorityResolver = new PerJobFixedPriorityConflictResolver
		rules.forEach[fixedPriorityResolver.setPriority(rule.ruleSpecification, priority)]
		
		val executionSchemaBuilder = new ExecutionSchemaBuilder
		executionSchemaBuilder.engine = engine
		executionSchemaBuilder.scheduler = schedulerFactory
		executionSchemaBuilder.conflictResolver = fixedPriorityResolver
		val executionSchema = executionSchemaBuilder.build
		
		transformationBuilder.schema = executionSchema
		rules.forEach[transformationBuilder.addRule(rule)]		
		transformation = transformationBuilder.build
		
		
		initialized = true
	}
	
	def initRules(IJDTManipulator manipulator) {
		val list = newArrayList
		list.add(new PrioritizedRule(ruleFactory.createRule.precondition(UmlClassQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				val qualifiedName = JDTQualifiedName::create(UMLQualifiedName::create(it.valueOfClass.qualifiedName))
				manipulator.createClass(qualifiedName)
			].action(IncQueryActivationStateEnum.UPDATED) [
				
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				val qualifiedName = JDTQualifiedName::create(UMLQualifiedName::create(it.valueOfClass.qualifiedName))
				manipulator.deleteClass(qualifiedName)
			].build, 0))
		list.add(new PrioritizedRule(ruleFactory.createRule.precondition(AssociationOfClassQuerySpecification::instance)
			.action(IncQueryActivationStateEnum.APPEARED) [
				val containingClassQN = JDTQualifiedName::create(UMLQualifiedName::create(it.valueOfClass.qualifiedName))
				val fieldName = it.association.name
				val typeQN = JDTQualifiedName::create(UMLQualifiedName::create(it.endType.qualifiedName))
				manipulator.createField(containingClassQN, fieldName, typeQN)
			].action(IncQueryActivationStateEnum.UPDATED) [
				
			].action(IncQueryActivationStateEnum.DISAPPEARED) [
				val assocQN = JDTQualifiedName::create(UMLQualifiedName::create(it.association.qualifiedName))
				manipulator.deleteField(assocQN)
			].build, 1))
			return list
	}
	
	
	def execute() {
		transformation.executionSchema.startUnscheduledExecution
	}
	
}

@Data
class PrioritizedRule {
	EventDrivenTransformationRule<?, ?> rule
	int priority
}