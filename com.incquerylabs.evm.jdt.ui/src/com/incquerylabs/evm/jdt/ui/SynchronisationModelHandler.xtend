package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.Shell
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.uml2.uml.Model

class SynchronisationModelHandler  extends AbstractHandler {
	
	override execute(ExecutionEvent event) throws ExecutionException {
		var selection = HandlerUtil.getCurrentSelection(event);
		val shell = HandlerUtil.getActiveShellChecked(event)
		
		val workspace = ResourcesPlugin.getWorkspace();
		val root = workspace.getRoot();
		
		val model = selection.umlModel
		val umlResource = model.eResource
		val umlResourceUri = umlResource.URI
		// TODO: get file of resource, and project of that file
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
	
	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
}
