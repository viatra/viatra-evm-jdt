package com.incquerylabs.evm.jdt.job

import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.jdt.core.IJavaElement

class JDTJobFactory {
	static def createJob(ActivationState activationState, (Activation<? extends IJavaElement>, Context)=>void task) {
		return new JDTJob(activationState) {
			override protected execute(Activation<? extends IJavaElement> activation, Context context) {
				task.apply(activation, context)
			}
		};
	}
}