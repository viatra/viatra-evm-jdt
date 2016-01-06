package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.expressions.PropertyTester
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.uml2.uml.Model

class SelectionAdapterTester extends PropertyTester {

    extension RunningSynchronizationManager manager = RunningSynchronizationManager.INSTANCE

    override test(Object receiver, String property, Object[] args, Object expectedValue) {
        if (receiver instanceof IAdaptable) {
            val model = receiver.getAdapter(Model)
            if (model != null) {
                switch (property) {
                    case "isumlmodel": {
                        val modelPlatformPath = model.eResource.getURI.toPlatformString(true)
                        if (modelPlatformPath != null) {
                            return true
                        }
                    }
                    case "isJava2UML": {
                        val synch = getSynchronization(model)
                        return synch?.dir == UMLJavaSynchronizationDirection.JAVA2UML
                    }
                    case "isUML2Java": {
                        val synch = getSynchronization(model)
                        return synch?.dir == UMLJavaSynchronizationDirection.UML2JAVA
                    }
                }
            }
        }
        return false
    }
}
