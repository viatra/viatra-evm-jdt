package com.incquerylabs.evm.jdt.uml.transformation

import com.incquerylabs.evm.jdt.JDTActivationLifeCycle
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.uml.transformation.rules.CompilationUnitRule
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.TransactionalManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.UMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.logger.UMLManipulationLogger
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Executor
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.Scheduler
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.papyrus.infra.core.resource.ModelSet
import org.eclipse.uml2.uml.Model

class JDTUMLTransformation {
	extension val Logger logger = Logger.getLogger(this.class)
	
	val JDTRealm jdtRealm
	val RuleEngine ruleEngine
	IUMLManipulator umlManipulator
	Executor executor
	Scheduler scheduler

	new() {
		this.jdtRealm = new JDTRealm
		this.executor = new Executor(jdtRealm)
		this.ruleEngine = RuleEngine.create(executor.ruleBase);
		this.umlManipulator = new UMLManipulationLogger
	}

	def void start(IJavaProject project, Model model) {
		ruleEngine.logger.level = Level.INFO
		logger.level = Level.DEBUG
		debug('''Transformation starting...''')
		
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		
		umlManipulator = new UMLManipulator(model)
		val modelSet = model.eResource.resourceSet
		if(modelSet instanceof ModelSet) {
			umlManipulator = new TransactionalManipulator(umlManipulator, modelSet.transactionalEditingDomain)
		}
		
//		val loggerRule = new LoggerRule(sourceSpec, lifeCycle, project)
//		addRule(loggerRule)
//		val classRule = new ClassRule(sourceSpec, lifeCycle, project, umlManipulator)
//		addRule(classRule)
//		val associationRule = new AssociationRule(sourceSpec, lifeCycle, project, umlManipulator)
//		addRule(associationRule)
		val compilationUnitRule = new CompilationUnitRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(compilationUnitRule)
		
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
