package com.incquerylabs.evm.jdt.java.transformation

import com.google.common.base.Preconditions
import com.incquerylabs.evm.jdt.fqnutil.impl.JDTElementLocator
import com.incquerylabs.evm.jdt.java.transformation.queries.UmlQueries
import com.incquerylabs.evm.jdt.java.transformation.rules.AssociationRules
import com.incquerylabs.evm.jdt.java.transformation.rules.ClassRules
import com.incquerylabs.evm.jdt.java.transformation.rules.RuleProvider
import com.incquerylabs.evm.jdt.jdtmanipulator.impl.JDTManipulator
import java.util.Map
import org.eclipse.incquery.runtime.api.GenericPatternGroup
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.incquery.runtime.emf.EMFScope
import org.eclipse.incquery.runtime.evm.api.Scheduler.ISchedulerFactory
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.incquery.runtime.evm.specific.resolver.InvertedDisappearancePriorityConflictResolver
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.EventDrivenTransformation
import org.eclipse.viatra.emf.runtime.transformation.eventdriven.ExecutionSchemaBuilder

class UMLToJavaTransformation {

	static val umlQueries = UmlQueries::instance
	
	// TODO: this is a temporary solution
	Map<Element, String> elementNameRegistry = newHashMap
	
	IncQueryEngine engine
	ISchedulerFactory schedulerFactory
	EventDrivenTransformation transformation

	JDTManipulator manipulator
	
	boolean initialized = false
	
	
	new(IJavaProject project, Model model) {
		manipulator = new JDTManipulator(new JDTElementLocator(project))
		engine = IncQueryEngine::on(new EMFScope(model))	
	}
	
	
	def void initialize() {
		Preconditions.checkArgument(engine != null, "Engine cannot be null!")
		if(!initialized) {
			if(schedulerFactory == null) {
				schedulerFactory = Schedulers.getIQEngineSchedulerFactory(engine)
			}			
		}
		
		val ruleProviders = <RuleProvider>newArrayList
		ruleProviders += new ClassRules
		ruleProviders += new AssociationRules
		
		ruleProviders.forEach[initialize(manipulator, elementNameRegistry)]
		
		val queries = GenericPatternGroup::of(umlQueries)
		queries.prepare(engine)
		
		val transformationBuilder = EventDrivenTransformation::forEngine(engine)
		
		val fixedPriorityResolver = new InvertedDisappearancePriorityConflictResolver
		ruleProviders.forEach[registerRules(fixedPriorityResolver)]
				
		val executionSchemaBuilder = new ExecutionSchemaBuilder
		executionSchemaBuilder.engine = engine
		executionSchemaBuilder.scheduler = schedulerFactory
		executionSchemaBuilder.conflictResolver = fixedPriorityResolver
		val executionSchema = executionSchemaBuilder.build
		
		transformationBuilder.schema = executionSchema
		ruleProviders.forEach[addRules(transformationBuilder)]		
		transformation = transformationBuilder.build
		
		
		initialized = true
	}
	
	def execute() {
		transformation.executionSchema.startUnscheduledExecution
	}
	
}