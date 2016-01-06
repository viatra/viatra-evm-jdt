package com.incquerylabs.evm.jdt.ui

import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.Shell
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.uml2.uml.Model

abstract class UMLModelHandler extends AbstractHandler {

	override Object execute(ExecutionEvent event) throws ExecutionException {
		val selection = HandlerUtil.getCurrentSelection(event) as IStructuredSelection;
		//val shell = HandlerUtil.getActiveShellChecked(event)

		val workspace = ResourcesPlugin.getWorkspace()
		val root = workspace.getRoot()

		val model = selection.umlModel
		val umlResource = model.eResource
		val umlResourceUri = umlResource.URI
		val projectName = umlResourceUri.segment(1)
		val project = root.getProject(projectName)

		project.startTransformation(model)

		return null
	}

	// TODO following code is copied from SyncronisationModelHandler, this needs to be extracted in a common class
	private def getUmlModel(ISelection selection) {
		var Model model
		if (selection instanceof IStructuredSelection) {
			val selectedElement = selection.toList.head;
			if (selectedElement instanceof Model) {
				model = selectedElement
			} else if (selectedElement instanceof IAdaptable) {
				val adaptableElement = selectedElement as IAdaptable;
				model = adaptableElement.getAdapter(Model) as Model
			}
		}
	}

	def protected void startTransformation(IProject project, Model model)

	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
}
