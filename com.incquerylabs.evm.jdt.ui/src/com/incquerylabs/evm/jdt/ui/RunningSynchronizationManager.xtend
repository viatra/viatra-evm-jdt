package com.incquerylabs.evm.jdt.ui

import java.util.Map
import org.eclipse.uml2.uml.Model

class RunningSynchronizationManager {
    
    val Map<Model, BidirectionalSynchronization> runningSynchronizations = newHashMap
    public static RunningSynchronizationManager INSTANCE = new RunningSynchronizationManager
    
    private new(){}
    
    def void synchronizationStarted(Model model, BidirectionalSynchronization synch) {
        runningSynchronizations.put(model, synch)
    }
    
    def BidirectionalSynchronization getSynchronization(Model model) {
        runningSynchronizations.get(model)
    }
    
    def BidirectionalSynchronization cleanupSynchronization(Model model) {
        runningSynchronizations.remove(model)
    }
}
