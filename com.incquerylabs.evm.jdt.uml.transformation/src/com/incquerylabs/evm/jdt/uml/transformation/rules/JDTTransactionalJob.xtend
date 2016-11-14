package com.incquerylabs.evm.jdt.uml.transformation.rules

import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.viatra.integration.evm.jdt.JDTEventAtom
import org.eclipse.viatra.integration.evm.jdt.job.JDTJob
import org.eclipse.viatra.transformation.evm.api.Activation
import org.eclipse.viatra.transformation.evm.api.Context
import org.eclipse.viatra.transformation.evm.api.event.ActivationState

abstract class JDTTransactionalJob extends JDTJob {
	val TransactionalEditingDomain domain
	
	protected new(ActivationState activationState, TransactionalEditingDomain domain) {
		super(activationState)
		this.domain = domain
	}
	
	override protected execute(Activation<? extends JDTEventAtom> activation, Context context) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				JDTTransactionalJob.super.execute(activation, context)
			}
		}
		domain.commandStack.execute(command)
	}
}
