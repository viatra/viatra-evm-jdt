package com.incquerylabs.emdw.jdtuml.application

import com.google.common.collect.Sets
import com.incquerylabs.emdw.jdtuml.JDTActivationState
import com.incquerylabs.emdw.jdtuml.JDTEventFilter
import com.incquerylabs.emdw.jdtuml.JDTEventSourceSpecification
import com.incquerylabs.emdw.jdtuml.JDTEventType
import com.incquerylabs.emdw.jdtuml.JDTRealm
import java.util.Arrays
import org.apache.log4j.Level
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.EventDrivenVM
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.incquery.runtime.evm.api.event.EventType.RuleEngineEventType
import org.eclipse.jdt.core.IJavaElementDelta

import static extension com.incquerylabs.emdw.jdtuml.util.JDTChangeFlagDecoder.toChangeFlags

class JDTEventDrivenApp {
	final RuleEngine engine

	/** 
	 * @param jdtRealm
	 */
	new(JDTRealm jdtRealm) {
		this.engine = EventDrivenVM::createRuleEngine(jdtRealm)
	}

	def void start() {
		engine.getLogger().setLevel(Level::DEBUG)
		val ActivationLifeCycle lifeCycle = ActivationLifeCycle::create(JDTActivationState::INACTIVE)
		lifeCycle.addStateTransition(JDTActivationState::INACTIVE, JDTEventType::APPEARED, JDTActivationState::APPEARED)
		lifeCycle.addStateTransition(JDTActivationState::INACTIVE, JDTEventType::DISAPPEARED, JDTActivationState::DISAPPEARED)
		lifeCycle.addStateTransition(JDTActivationState::INACTIVE, JDTEventType::UPDATED, JDTActivationState::UPDATED)
		lifeCycle.addStateTransition(JDTActivationState::APPEARED, RuleEngineEventType::FIRE, JDTActivationState::INACTIVE)
		lifeCycle.addStateTransition(JDTActivationState::DISAPPEARED, RuleEngineEventType::FIRE, JDTActivationState::INACTIVE)
		lifeCycle.addStateTransition(JDTActivationState::UPDATED, RuleEngineEventType::FIRE, JDTActivationState::INACTIVE)
		
		val Job<IJavaElementDelta> job = new Job<IJavaElementDelta>(JDTActivationState::UPDATED) {
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
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification()
		val RuleSpecification<IJavaElementDelta> ruleSpec = new RuleSpecification<IJavaElementDelta>(sourceSpec,
			lifeCycle, Sets::newHashSet(job))
		val JDTEventFilter filter = sourceSpec.createEmptyFilter() as JDTEventFilter
		engine.addRule(ruleSpec, filter)
	}

	def void fire() {
		engine.getNextActivation().fire(Context::create())
	}

}
