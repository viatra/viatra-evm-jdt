package com.incquerylabs.emdw.jdtuml.application

import com.incquerylabs.emdw.jdtuml.JDTActivationLifeCycle
import com.incquerylabs.emdw.jdtuml.JDTActivationState
import com.incquerylabs.emdw.jdtuml.JDTEventFilter
import com.incquerylabs.emdw.jdtuml.JDTEventSourceSpecification
import com.incquerylabs.emdw.jdtuml.JDTRealm
import com.incquerylabs.emdw.jdtuml.job.JDTLoggerJob
import java.util.Set
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.EventDrivenVM
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore

class JDTEventDrivenApp {
	extension val Logger logger = Logger.getLogger(this.class)
	
	val JDTRealm jdtRealm
	val RuleEngine engine

	new() {
		this.jdtRealm = new JDTRealm
		this.engine = EventDrivenVM::createRuleEngine(jdtRealm)
	}

	def void start(IJavaProject project) {
		engine.getLogger().setLevel(Level::DEBUG)
		logger.level = Level.DEBUG
		debug('''Transformation starting...''')
		
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val jobs = <Job<IJavaElement>>newHashSet()
		jobs.addLoggerJobs
		
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		val RuleSpecification<IJavaElement> ruleSpec = new RuleSpecification<IJavaElement>(
			sourceSpec, lifeCycle, jobs
		)
		val JDTEventFilter filter = sourceSpec.createEmptyFilter() as JDTEventFilter
		filter.project = project
		engine.addRule(ruleSpec, filter)
		
		
		addJDTEventListener
	}
	
	private def addJDTEventListener() {
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			jdtRealm.pushChange(event.delta)
			this.fire()
		] as IElementChangedListener))
	}
	
	private def addLoggerJobs(Set<Job<IJavaElement>> jobs){
		jobs.add(new JDTLoggerJob(JDTActivationState::APPEARED))
		jobs.add(new JDTLoggerJob(JDTActivationState::DISAPPEARED))
		jobs.add(new JDTLoggerJob(JDTActivationState::UPDATED))
	}

	def void fire() {
		val activation = engine.nextActivation
		if(activation == null){
			debug('''Activation was null''')
			return
		}
		activation.fire(Context::create())
	}
	
}
