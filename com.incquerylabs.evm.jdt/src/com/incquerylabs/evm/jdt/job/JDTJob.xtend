package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.apache.log4j.Logger
import org.eclipse.viatra.transformation.evm.api.Activation
import org.eclipse.viatra.transformation.evm.api.Context
import org.eclipse.viatra.transformation.evm.api.Job
import org.eclipse.viatra.transformation.evm.api.event.ActivationState

abstract class JDTJob extends Job<JDTEventAtom> {
	extension Logger logger = Logger.getLogger(this.class)
	
	protected new(ActivationState activationState) {
		super(activationState)
	}
	
	override protected execute(Activation<? extends JDTEventAtom> activation, Context context) {
		run(activation, context)
	}
	
	def abstract protected void run(Activation<? extends JDTEventAtom> activation, Context context)
	
	override protected handleError(Activation<? extends JDTEventAtom> activation, Exception exception, Context context) {
		error('''Unhandled error in JDTJob.''', exception)
	}
	
}