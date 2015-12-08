package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.Shell
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.core.resources.IProject

class JavaProjectHandler extends AbstractHandler {
	override Object execute(ExecutionEvent event) throws ExecutionException {
		val selection = HandlerUtil.getCurrentSelection(event);
		val project = selection.javaProject
		val shell = HandlerUtil.getActiveShellChecked(event)
		
		if(project == null) {
			reportError(shell, null, "Invalid target",
				'''The transformation can only be started on Java projects'''
			)
			return null
		}
		
		project.startTransformation
		
		return null
	}
	
	def private getJavaProject(ISelection selection) {
		if(selection instanceof IStructuredSelection) {
			val selectedElement = selection.firstElement
			if(selectedElement instanceof IJavaProject) {
				return selectedElement
			} else if (selectedElement instanceof IAdaptable) {
				return selectedElement.getAdapter(IJavaProject)
			}
		}
	}

	def private void startTransformation(IJavaProject project) {
		System::out.println('''Working on project «project.elementName»'''.toString)
		val JDTUMLTransformation umlTransformation = new JDTUMLTransformation()
		val model = project.project.getUmlModel
		umlTransformation.start(project, model)
	}
	
	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
	
	private def getUmlModel(IProject project) {
		val projectPath = project.fullPath
		val modelPath = projectPath.append("/model/model.uml")
		
		val umlUri = URI.createPlatformResourceURI(modelPath.toString, true)
		val resourceSet = new ResourceSetImpl
		val umlResource = resourceSet.getOrCreateResource(umlUri)
		umlResource.load(null)
		val model = umlResource.getOrCreateUmlModel
		return model
	}
	
	private def getOrCreateResource(ResourceSet resourceSet, URI resourceUri) {
		val umlResource = resourceSet.getResource(resourceUri, true)
		// TODO create UML model if it does not exist
		return umlResource
	}
	
	private def getOrCreateUmlModel(Resource umlResource) {
		val contents = umlResource.contents
		
		if(!contents.isEmpty) {
			val model = contents.filter(Model).head
			if(model!=null) {
				return model
			}
		}
		val model = UMLFactory.eINSTANCE.createModel
		contents += model
		umlResource.save(null)
		return model
	}
}
