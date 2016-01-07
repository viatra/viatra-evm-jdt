package com.incquerylabs.evm.jdt.ui.manager

import java.util.Map
import org.eclipse.uml2.uml.Model
import org.eclipse.ui.AbstractSourceProvider
import org.eclipse.ui.ISources
import com.incquerylabs.evm.jdt.ui.BidirectionalSynchronization

class RunningSynchronizationManager extends AbstractSourceProvider {
    
    public static val ANY_SYNCHRONIZATION_RUNNING = "com.incquerylabs.evm.jdt.ui.anySynchronizationRunning"
    
    val Map<Model, BidirectionalSynchronization> runningSynchronizations = newHashMap
    public static RunningSynchronizationManager INSTANCE = new RunningSynchronizationManager
    
    private new(){}
    
    def void synchronizationStarted(Model model, BidirectionalSynchronization synch) {
        val firstSynch = runningSynchronizations.isEmpty
        runningSynchronizations.put(model, synch)
        if (firstSynch) {
            fireSourceChanged(ISources.WORKBENCH, ANY_SYNCHRONIZATION_RUNNING, true)
        }
    }
    
    def BidirectionalSynchronization getSynchronization(Model model) {
        runningSynchronizations.get(model)
    }
    
    def BidirectionalSynchronization cleanupSynchronization(Model model) {
        val synch = runningSynchronizations.remove(model)
        if (runningSynchronizations.empty) {
            fireSourceChanged(ISources.WORKBENCH, ANY_SYNCHRONIZATION_RUNNING, false)
        }
        synch
    }
    
    def hasAnySynchronizationRunning() {
        !runningSynchronizations.isEmpty
    }
    
    def void cleanupAllSynchronizations() {
        runningSynchronizations.forEach[model, synchronization|synchronization.dispose]
        runningSynchronizations.clear
        fireSourceChanged(ISources.WORKBENCH, ANY_SYNCHRONIZATION_RUNNING, false)
    }
    
    override dispose() {
        cleanupAllSynchronizations
    }
    
    override Map<String, Object> getCurrentState() {
        newHashMap(
            ANY_SYNCHRONIZATION_RUNNING -> hasAnySynchronizationRunning
        )
    }
    
    override getProvidedSourceNames() {
        return #[ANY_SYNCHRONIZATION_RUNNING]
    }
    
}
