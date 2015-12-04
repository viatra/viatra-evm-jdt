package com.incquerylabs.evm.jdt.uml.transformation

import com.incquerylabs.evm.jdt.JDTActivationLifeCycle
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.uml.transformation.rules.ClassRule
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Executor
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.Scheduler
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.logger.UMLManipulationLogger
import com.incquerylabs.evm.jdt.uml.transformation.rules.LoggerRule

class JDTUMLTransformation {
	extension val Logger logger = Logger.getLogger(this.class)
	
	val JDTRealm jdtRealm
	val RuleEngine ruleEngine
	val IUMLManipulator umlManipulator
	Executor executor
	Scheduler scheduler

	new() {
		this.jdtRealm = new JDTRealm
		this.executor = new Executor(jdtRealm)
		this.ruleEngine = RuleEngine.create(executor.ruleBase);
		this.umlManipulator = new UMLManipulationLogger
	}

	def void start(IJavaProject project) {
		ruleEngine.logger.level = Level.INFO
		logger.level = Level.DEBUG
		debug('''Transformation starting...''')
		
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		
		val loggerRule = new LoggerRule(sourceSpec, lifeCycle, project)
		val classRule = new ClassRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(loggerRule)
		addRule(classRule)
		
		addJDTEventListener
		addTimedScheduler(100)
	}
	
	def addTimedScheduler(long interval) {
		val schedulerFactory = Schedulers.getTimedSchedulerFactory(interval)
		this.scheduler = schedulerFactory.prepareScheduler(executor)
	}
	
	def addRule(JDTRule rule) {
		ruleEngine.addRule(rule.ruleSpecification, rule.filter)
	}
	
	private def addJDTEventListener() {
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			jdtRealm.pushChange(event.delta)
		] as IElementChangedListener))
	}
}
