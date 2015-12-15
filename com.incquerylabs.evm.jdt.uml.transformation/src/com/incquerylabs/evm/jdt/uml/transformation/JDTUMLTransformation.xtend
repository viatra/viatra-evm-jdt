package com.incquerylabs.evm.jdt.uml.transformation

import com.incquerylabs.evm.jdt.JDTActivationLifeCycle
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import com.incquerylabs.evm.jdt.uml.transformation.rules.CompilationUnitRule
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.TransactionalManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.UMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.logger.UMLManipulationLogger
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.api.GenericPatternGroup
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.incquery.runtime.emf.EMFScope
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Executor
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.Scheduler
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.papyrus.infra.core.resource.ModelSet
import org.eclipse.uml2.uml.Model
import com.incquerylabs.evm.jdt.uml.transformation.rules.PackageRule

class JDTUMLTransformation {
	extension val Logger logger = Logger.getLogger(this.class)
	static val UmlQueries umlQueries = UmlQueries.instance
	
	val JDTRealm jdtRealm
	val RuleEngine ruleEngine
	IUMLManipulator umlManipulator
	Executor executor
	Scheduler scheduler

	IncQueryEngine engine
	
	new() {
		this.jdtRealm = new JDTRealm
		this.executor = new Executor(jdtRealm)
		this.ruleEngine = RuleEngine.create(executor.ruleBase);
		this.umlManipulator = new UMLManipulationLogger
	}

	def void start(IJavaProject project, Model model) {
		ruleEngine.logger.level = Level.INFO
		logger.level = Level.DEBUG
		debug('''Started Java to UML transformation.''')
		
		// Initialize IncQueryEngine
		this.engine = IncQueryEngine::on(new EMFScope(model))
		val queries = GenericPatternGroup::of(umlQueries)
		queries.prepare(engine)
		
		// Initialize the UMLManipulator
		umlManipulator = new UMLManipulator(model, engine)
		val modelSet = model.eResource.resourceSet
		if(modelSet instanceof ModelSet) {
			umlManipulator = new TransactionalManipulator(umlManipulator, modelSet.transactionalEditingDomain)
		}
		
		// Initialize and add rules
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification

		val compilationUnitRule = new CompilationUnitRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(compilationUnitRule)
		val packageRule = new PackageRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(packageRule)
		
		// Add scheduler for EVM
		addTimedScheduler(100)
	}
	
	def addTimedScheduler(long interval) {
		val schedulerFactory = Schedulers.getTimedSchedulerFactory(interval)
		this.scheduler = schedulerFactory.prepareScheduler(executor)
	}
	
	def addRule(JDTRule rule) {
		ruleEngine.addRule(rule.ruleSpecification, rule.filter)
	}
	
}
