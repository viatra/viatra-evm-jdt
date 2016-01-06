package com.incquerylabs.evm.jdt.job

import org.eclipse.incquery.runtime.evm.api.Context
import com.incquerylabs.evm.jdt.JDTEventAtom
import org.eclipse.incquery.runtime.evm.api.Activation

interface JDTJobTask {
	def void run(Activation<? extends JDTEventAtom> activation, Context context)
}