package com.incquerylabs.evm.jdt.ui.manager

import org.eclipse.core.runtime.IExecutableExtensionFactory
import org.eclipse.core.runtime.CoreException

class SynchronizationManagerFactory implements IExecutableExtensionFactory {
    
    override create() throws CoreException {
        RunningSynchronizationManager.INSTANCE
    }
    
}