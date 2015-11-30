package com.incquerylabs.emdw.jdtevents.experimentapp

import com.google.common.collect.Sets
import com.incquerylabs.emdw.jdtevents.experiment.JDTActivationState
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventFilter
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSourceSpecification
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventType
import com.incquerylabs.emdw.jdtevents.experiment.JDTRealm
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
import com.incquerylabs.emdw.jdtutil.JDTChangeFlagDecoder

import static extension com.incquerylabs.emdw.jdtutil.JDTChangeFlagDecoder.toChangeFlags
import com.incquerylabs.emdw.jdtutil.ChangeFlag
import com.google.common.collect.ImmutableList.Builder

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
		lifeCycle.addStateTransition(JDTActivationState::INACTIVE, JDTEventType::ELEMENT_CHANGED,
			JDTActivationState::ACTIVE)
		lifeCycle.addStateTransition(JDTActivationState::ACTIVE, RuleEngineEventType::FIRE,
			JDTActivationState::INACTIVE)
		val Job<IJavaElementDelta> job = new Job<IJavaElementDelta>(JDTActivationState::ACTIVE) {
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
