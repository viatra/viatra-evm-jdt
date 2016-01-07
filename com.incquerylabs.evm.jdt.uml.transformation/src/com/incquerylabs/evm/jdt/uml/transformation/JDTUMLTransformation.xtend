package com.incquerylabs.evm.jdt.uml.transformation

import com.incquerylabs.evm.jdt.JDTActivationLifeCycle
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.job.JDTTransactionalJobFactory
import com.incquerylabs.evm.jdt.transactions.JDTTransactionalEventSourceSpecification
import com.incquerylabs.evm.jdt.transactions.JDTTransactionalLifecycle
import com.incquerylabs.evm.jdt.uml.transformation.rules.PackageRule
import com.incquerylabs.evm.jdt.uml.transformation.rules.TransactionalCompilationUnitRule
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import com.incquerylabs.evm.jdt.umlmanipulator.impl.UMLModelAccessImpl
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.ResourceSet
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
import java.util.Set
import org.eclipse.incquery.runtime.evm.specific.job.EnableJob

class JDTUMLTransformation {
	extension val Logger logger = Logger.getLogger(this.class)
	static val UmlQueries umlQueries = UmlQueries.instance
	
	val JDTRealm jdtRealm
	val RuleEngine ruleEngine
	UMLModelAccess umlModelAccess
	Executor executor
	Scheduler scheduler

	Set<JDTRule> rules = newHashSet

	IncQueryEngine engine
	
	new() {
		this.jdtRealm = JDTRealm::instance
		this.executor = new Executor(jdtRealm)
		this.ruleEngine = RuleEngine.create(executor.ruleBase);
	}

	def void start(IJavaProject project, Model model) {
		ruleEngine.logger.level = Level.DEBUG
		logger.level = Level.DEBUG
		debug('''Started Java to UML transformation.''')
		
		// Initialize IncQueryEngine
		this.engine = IncQueryEngine::on(new EMFScope(model))
		val queries = GenericPatternGroup::of(umlQueries)
		queries.prepare(engine)
		
		// Initialize the UMLManipulator
		umlModelAccess = new UMLModelAccessImpl(model, engine)
		val modelSet = model.eResource.resourceSet
		
		// Initialize and add transactional rules
		val transactionalLifeCycle = new JDTTransactionalLifecycle
		val JDTTransactionalEventSourceSpecification transactionalSourceSpec = new JDTTransactionalEventSourceSpecification
		val jobFactory = createJobFactory(modelSet)
		val transactionalCompilationUnitRule = new TransactionalCompilationUnitRule(transactionalSourceSpec, transactionalLifeCycle, project, umlModelAccess, jobFactory)
		addRule(transactionalCompilationUnitRule)
		
		// Initialize and add other rules
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		val packageRule = new PackageRule(sourceSpec, lifeCycle, project, umlModelAccess, jobFactory)
		addRule(packageRule)
		
		enableSynchronization
		
		// Add scheduler for EVM
		addTimedScheduler(100)
	}
	
	private def JDTJobFactory createJobFactory(ResourceSet resourceSet) {
		if(resourceSet instanceof ModelSet) {
			return new JDTTransactionalJobFactory(resourceSet.transactionalEditingDomain)
		}
		return new JDTJobFactory
	}
	
	def addTimedScheduler(long interval) {
		val schedulerFactory = Schedulers.getTimedSchedulerFactory(interval)
		this.scheduler = schedulerFactory.prepareScheduler(executor)
	}
	
	def addRule(JDTRule rule) {
		rules.add(rule)
		ruleEngine.addRule(rule.ruleSpecification, rule.filter)
	}
	
	def disableSynchronization() {
		rules.forEach[
			jobs.forEach[job |
				if(job instanceof EnableJob){
					job.enabled = false
				}
			]
		]
	}
	
	def enableSynchronization() {
		rules.forEach[
			jobs.forEach[job |
				if(job instanceof EnableJob){
					job.enabled = true
				}
			]
		]
	}
	
	def dispose() {
	    ruleEngine.dispose
	}
}
