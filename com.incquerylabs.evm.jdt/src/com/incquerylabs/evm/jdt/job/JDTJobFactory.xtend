package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.incquery.runtime.evm.specific.job.ErrorLoggingJob

class JDTJobFactory {
	static def createJob(ActivationState activationState, (Activation<? extends JDTEventAtom>, Context)=>void task) {
		val jdtJob = new JDTJob(activationState) {
			override protected execute(Activation<? extends JDTEventAtom> activation, Context context) {
				task.apply(activation, context)
			}
		}
		
		return new ErrorLoggingJob(jdtJob)
	}
}