package com.incquerylabs.evm.jdt.job

import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.apache.log4j.Logger

abstract class JDTJob extends Job<IJavaElement> {
	extension Logger logger = Logger.getLogger(this.class)
	
	protected new(ActivationState activationState) {
		super(activationState)
	}
	
	override protected handleError(Activation<? extends IJavaElement> activation, Exception exception, Context context) {
		error('''Unhandled error in JDTJob.''')
	}
	
}