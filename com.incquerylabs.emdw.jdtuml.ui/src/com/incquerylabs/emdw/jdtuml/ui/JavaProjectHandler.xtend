package com.incquerylabs.emdw.jdtuml.ui

import com.incquerylabs.emdw.jdtuml.application.JDTEventDrivenApp
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
		val JDTEventDrivenApp jdtApp = new JDTEventDrivenApp()
		jdtApp.start(project)
	}
	
	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
}
