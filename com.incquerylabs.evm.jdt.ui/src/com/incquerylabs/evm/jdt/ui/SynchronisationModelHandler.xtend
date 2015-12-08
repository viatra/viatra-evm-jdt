package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Shell
import org.eclipse.jdt.core.IJavaProject
import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import org.eclipse.jdt.core.JavaCore

class SynchronisationModelHandler  extends AbstractHandler {
	
	override execute(ExecutionEvent event) throws ExecutionException {
		var selection = HandlerUtil.getCurrentSelection(event);
		val shell = HandlerUtil.getActiveShellChecked(event)
		
		val workspace = ResourcesPlugin.getWorkspace();
		val root = workspace.getRoot();
		
		val model = selection.umlModel
		val umlResource = model.eResource
		val umlResourceUri = umlResource.URI
		val projectName = umlResourceUri.segment(1)
		val project = root.getProject(projectName)
		
		if(project != null && project.isNatureEnabled("org.eclipse.jdt.core.javanature")) {
			val javaProject = JavaCore.create(project);
			System::out.println('''Working on project «javaProject.elementName»'''.toString)
			val JDTUMLTransformation umlTransformation = new JDTUMLTransformation()
			umlTransformation.start(javaProject, model)
		} else {
			reportError(shell, null, "Invalid target",
				'''The transformation can only be started on Java projects'''
			)
		}
		
		return null;
	}
	
	
	def getUmlModel(ISelection selection) {
		var Model model
		if (selection instanceof IStructuredSelection){
			val selectedElement = selection.toList.head; 
			if (selectedElement instanceof Model){
				model = selectedElement
			} else if (selectedElement instanceof IAdaptable){
				val adaptableElement = selectedElement as IAdaptable;
				model = adaptableElement.getAdapter(Model) as Model
			}
		}
	}
	
	private def getUmlModel(IProject project) {
		val projectPath = project.fullPath
		val modelPath = projectPath.append("/model/model.uml")
		
		val umlUri = URI.createPlatformResourceURI(modelPath.toString, true)
		// TODO get resource set
		val resourceSet = null
		val umlResource = getOrCreateResource(resourceSet, umlUri)
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
	
	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
}
