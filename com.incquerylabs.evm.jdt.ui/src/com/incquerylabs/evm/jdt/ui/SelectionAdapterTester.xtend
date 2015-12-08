package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.expressions.PropertyTester
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.uml2.uml.Model

class SelectionAdapterTester extends PropertyTester {
	
	override test(Object receiver, String property, Object[] args, Object expectedValue) {
		if(property == "isumlmodel"){
			if (receiver instanceof IAdaptable){
				val model = receiver.getAdapter(Model)
				if(model != null){
					val modelPlatformPath = model.eResource.getURI.toPlatformString(true)
					if(modelPlatformPath != null) {
						return true
					}
				}
			}
		}
		return false
	}
}
