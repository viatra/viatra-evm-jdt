package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTEventAtom
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.event.ActivationState

abstract class JDTJob extends Job<JDTEventAtom> {
	extension Logger logger = Logger.getLogger(this.class)
	
	protected new(ActivationState activationState) {
		super(activationState)
	}
	
	override protected handleError(Activation<? extends JDTEventAtom> activation, Exception exception, Context context) {
		error('''Unhandled error in JDTJob.''')
	}
	
}