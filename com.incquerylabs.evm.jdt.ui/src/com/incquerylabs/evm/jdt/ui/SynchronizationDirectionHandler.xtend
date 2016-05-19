package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.resources.IProject
import org.eclipse.uml2.uml.Model
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.ui.handlers.HandlerUtil
import com.incquerylabs.evm.jdt.ui.manager.RunningSynchronizationManager

class SynchronizationDirectionHandler extends UMLModelHandler {
	
	extension RunningSynchronizationManager manager = RunningSynchronizationManager.INSTANCE
	
	var boolean oldState
    
    override Object execute(ExecutionEvent event) throws ExecutionException {
        oldState = HandlerUtil.toggleCommandState(event.command)
        super.execute(event)
    }
	
	override protected startTransformation(IProject project, Model model) {
		
		val synch = getSynchronization(model)
		if(synch != null){
			synch.allowJava2UML
		}
	}
	
}