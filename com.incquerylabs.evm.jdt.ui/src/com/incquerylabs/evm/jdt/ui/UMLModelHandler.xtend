package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.java.transformation.UMLToJavaTransformation
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.Shell
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.uml2.uml.Model

class UMLModelHandler extends AbstractHandler {
	override Object execute(ExecutionEvent event) throws ExecutionException {
		val selection = HandlerUtil.getCurrentSelection(event) as IStructuredSelection;
		val shell = HandlerUtil.getActiveShellChecked(event)

		val model = selection.getModel
		if (model == null) {
			reportError(
				shell,
				null,
				"Invalid target",
				'''The transformation can only be on an UML model'''
			)
			return null
		}
		
		val project = selection.javaProject
		if (project == null) {
			reportError(
				shell,
				null,
				"Invalid target",
				'''The transformation can only be started in Java projects'''
			)
			return null
		}

		project.startTransformation(model)

		return null
	}

	def getModel(IStructuredSelection selection) {
		val firstSelectedElement = selection.firstElement
		if (firstSelectedElement instanceof IFile) {
			val path = firstSelectedElement.fullPath
			val rs = new ResourceSetImpl
			val resource = rs.getResource(URI::createPlatformResourceURI(path.toString, true), true)
			val model = resource.contents.get(0)
			if(model instanceof Model) {
				return model
			}
		}
			
	}

	def private getJavaProject(ISelection selection) {
		if (selection instanceof IStructuredSelection) {
			val selectedElement = selection.firstElement
			if (selectedElement instanceof IFile) {
				val project = selectedElement.project
				if(project instanceof IProject) {
					return JavaCore.create(project)
				} else if(project instanceof IJavaProject) {
					return project as IJavaProject
				} else if (project instanceof IAdaptable) {
					return project.getAdapter(IJavaProject)
				}
			}
		}
	}

	def private void startTransformation(IJavaProject project, Model model) {
		System::out.println('''Working on project «project.elementName»'''.toString)
		val transformation = new UMLToJavaTransformation(project, model)
		transformation.initialize()
		transformation.execute
	}

	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
}
