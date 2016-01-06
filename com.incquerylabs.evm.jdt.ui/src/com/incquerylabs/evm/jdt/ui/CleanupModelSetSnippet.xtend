package com.incquerylabs.evm.jdt.ui

import org.eclipse.papyrus.infra.core.resource.IModelSetSnippet
import org.eclipse.papyrus.infra.core.resource.ModelSet
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.resource.UMLResource

class CleanupModelSetSnippet implements IModelSetSnippet {
	
	override start(ModelSet modelSet) {
	}

	override dispose(ModelSet modelSet) {

		val umlResources = modelSet.resources.filter(UMLResource)
		val umlResource = umlResources.findFirst[URI.trimFileExtension.equals(modelSet.URIWithoutExtension)]
		val umlRoot = umlResource.contents.filter(Model).head
		val synch = SynchronisationModelHandler.runningSynchronizations.remove(umlRoot)
		if(synch != null) {
			synch.allowJava2UML
		}
	}
	
	
}