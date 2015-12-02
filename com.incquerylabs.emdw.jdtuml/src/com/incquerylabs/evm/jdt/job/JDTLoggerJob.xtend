package com.incquerylabs.evm.jdt.job

import com.incquerylabs.evm.jdt.JDTActivationState
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.incquery.runtime.evm.api.Context
import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.jdt.core.IJavaElement

class JDTLoggerJob extends Job<IJavaElement> {
	extension Logger logger = Logger.getLogger(this.class)
	
	new(ActivationState activationState) {
		super(activationState)
		logger.level = Level.DEBUG
	}
	
	override protected execute(Activation<? extends IJavaElement> activation, Context context) {
		val javaElement = activation.getAtom()
		debug('''«message»: «javaElement»''')
	}
	
	override protected handleError(Activation<? extends IJavaElement> activation, Exception exception, Context context) {
		error('''Unhandled error in JDTLoggerJob.''')
	}
	
	def getMessage() {
		switch(this.activationState) {
			case JDTActivationState.APPEARED : '''An element has appeared'''
			case JDTActivationState.DISAPPEARED : '''An element has disappeared'''
			case JDTActivationState.UPDATED : '''An element has been updated'''
			default: '''Invalid actiovation state for element'''
		}
	}
	
}