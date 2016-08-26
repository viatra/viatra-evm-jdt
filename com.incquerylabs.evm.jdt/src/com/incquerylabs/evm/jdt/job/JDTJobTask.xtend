package com.incquerylabs.evm.jdt.job

import org.eclipse.viatra.transformation.evm.api.Context
import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.viatra.transformation.evm.api.Activation

interface JDTJobTask {
	def void run(Activation<? extends JDTEventAtom> activation, Context context)
}