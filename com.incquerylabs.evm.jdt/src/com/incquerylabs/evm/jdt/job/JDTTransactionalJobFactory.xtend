package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.viatra.transformation.evm.api.Activation
import org.eclipse.viatra.transformation.evm.api.Context
import org.eclipse.viatra.transformation.evm.api.event.ActivationState
import org.eclipse.viatra.transformation.evm.specific.job.ErrorLoggingJob

class JDTTransactionalJobFactory extends JDTJobFactory {
	val TransactionalEditingDomain domain
	
	new(TransactionalEditingDomain domain) {
		this.domain = domain
	}
	
	override createJob(ActivationState activationState, JDTJobTask task) {
		val jdtJob = new JDTTransactionalJob(activationState, domain) {
			override protected run(Activation<? extends JDTEventAtom> activation, Context context) {
				task.run(activation, context)
			}
		}
		
		return new ErrorLoggingJob(jdtJob)
	}
}