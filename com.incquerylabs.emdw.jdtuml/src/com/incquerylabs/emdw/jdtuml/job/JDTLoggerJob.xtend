package com.incquerylabs.emdw.jdtuml.job

import org.eclipse.incquery.runtime.evm.api.Job
import org.eclipse.incquery.runtime.evm.api.event.ActivationState
import org.eclipse.incquery.runtime.evm.api.Activation
import org.eclipse.jdt.core.IJavaElementDelta
import org.eclipse.incquery.runtime.evm.api.Context
import java.util.Arrays

import static extension com.incquerylabs.emdw.jdtuml.util.JDTChangeFlagDecoder.toChangeFlags
import org.apache.log4j.Logger
import org.apache.log4j.Level

class JDTLoggerJob extends Job<org.eclipse.jdt.core.IJavaElementDelta> {
	extension Logger logger = Logger.getLogger(this.class)
	
	new(ActivationState activationState) {
		super(activationState)
		logger.level = Level.DEBUG
	}
	
	override protected execute(Activation<? extends IJavaElementDelta> activation, Context context) {
		val IJavaElementDelta delta = activation.getAtom()
		debug("********** An element has changed **********")
		debug('''Delta: «delta.toString»''')
		debug('''Affected children: «Arrays::toString(delta.affectedChildren)»''')
		debug('''Change flags: «delta.flags.toChangeFlags»''')
		debug("********************************************")
	}
	
	override protected handleError(Activation<? extends IJavaElementDelta> activation, Exception exception, Context context) {
		error('''Unhandled error in JDTLoggerJob.''')
	}
	
}