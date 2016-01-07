package com.incquerylabs.evm.jdt.ui

import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.swt.widgets.Shell
import org.eclipse.ui.handlers.HandlerUtil

class JavaProjectHandler extends AbstractHandler {
	extension val Logger logger = Logger.getLogger(this.class)
	
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
		
		project.startJDTNotificationLogging
		
		return null
	}
	
	def private getJavaProject(ISelection selection) {
		if(selection instanceof IStructuredSelection) {
			val selectedElement = selection.firstElement
			if(selectedElement instanceof IJavaProject) {
				return selectedElement
			}
			if(selectedElement instanceof IProject){
				val javaProject = JavaCore::create(selectedElement)
				if(javaProject.exists){
					return javaProject
				}
			}
			if (selectedElement instanceof IAdaptable) {
				return selectedElement.getAdapter(IJavaProject)
			}
		}
	}

	def private void startJDTNotificationLogging(IJavaProject project) {
		logger.level = Level.DEBUG
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			debug(event.delta)
		] as IElementChangedListener))
	}

	def reportError(Shell shell, Throwable exception, String message, String details) {
		MessageDialog.openError(shell, message, details)
	}
	
}
