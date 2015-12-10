package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.event.ActivationState

class JDTJobFactory {
	static def createJob(ActivationState activationState, (Activation<? extends JDTEventAtom>, Context)=>void task) {
		return new JDTJob(activationState) {
			override protected execute(Activation<? extends JDTEventAtom> activation, Context context) {
				task.apply(activation, context)
			}
		};
	}
}