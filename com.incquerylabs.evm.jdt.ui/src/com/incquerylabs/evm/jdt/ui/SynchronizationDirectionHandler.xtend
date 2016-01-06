package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.resources.IProject
import org.eclipse.uml2.uml.Model

class SynchronizationDirectionHandler extends UMLModelHandler {
	
	override protected startTransformation(IProject project, Model model) {
		
		val synch = SynchronisationModelHandler.runningSynchronizations.get(model)
		if(synch != null){
			if(synch.dir == UMLJavaSynchronizationDirection.JAVA2UML){
				synch.allowUML2Java
			} else {
				synch.allowJava2UML
			}
		}
	}
	
}