package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.emf.transaction.TransactionalEditingDomain

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