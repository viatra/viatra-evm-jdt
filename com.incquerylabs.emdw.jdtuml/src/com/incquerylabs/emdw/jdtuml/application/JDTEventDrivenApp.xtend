package com.incquerylabs.emdw.jdtuml.application

import com.google.common.collect.Sets
import com.incquerylabs.emdw.jdtuml.JDTActivationLifeCycle
import com.incquerylabs.emdw.jdtuml.JDTActivationState
import com.incquerylabs.emdw.jdtuml.JDTEventFilter
import com.incquerylabs.emdw.jdtuml.JDTEventSourceSpecification
import com.incquerylabs.emdw.jdtuml.JDTRealm
import java.util.Arrays
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.EventDrivenVM
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore

import static extension com.incquerylabs.emdw.jdtuml.util.JDTChangeFlagDecoder.toChangeFlags

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
		val Job<IJavaElementDelta> job = defaultJob
		
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		val RuleSpecification<IJavaElementDelta> ruleSpec = new RuleSpecification<IJavaElementDelta>(
			sourceSpec, lifeCycle, Sets::newHashSet(job)
		)
		val JDTEventFilter filter = sourceSpec.createEmptyFilter() as JDTEventFilter
		filter.project = project
		engine.addRule(ruleSpec, filter)
		
		
		addJDTEventListener
	}
	
	private def Job<IJavaElementDelta> getDefaultJob() {
		new Job<IJavaElementDelta>(JDTActivationState::UPDATED) {
			override protected void execute(Activation<? extends IJavaElementDelta> activation, Context context) {
				val IJavaElementDelta delta = activation.getAtom()
				System::out.println("********** An element has changed **********")
				System::out.println('''Delta: «delta.toString»''')
				System::out.println('''Affected children: «Arrays::toString(delta.affectedChildren)»''')
				System::out.println('''AST: «delta.compilationUnitAST»''')
				System::out.println('''Change flags: «delta.flags.toChangeFlags»''')
				System::out.println("********************************************")
			}

			override protected void handleError(Activation<? extends IJavaElementDelta> activation, Exception exception,
				Context context) {
				// not gonna happen
			}
		}
	}
	
	private def addJDTEventListener() {
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			jdtRealm.pushChange(event.delta)
			this.fire()
		] as IElementChangedListener))
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
