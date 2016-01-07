package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import com.incquerylabs.evm.jdt.ui.manager.RunningSynchronizationManager

class ResetAllSynchronizationHandler extends AbstractHandler {
    override Object execute(ExecutionEvent event) throws ExecutionException {
        RunningSynchronizationManager.INSTANCE.cleanupAllSynchronizations()
        return null
    }
}
