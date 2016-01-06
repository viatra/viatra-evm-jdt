package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.java.transformation.UMLToJavaTransformation
import com.incquerylabs.evm.jdt.uml.transformation.JDTUMLTransformation
import java.util.Map
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.uml2.uml.Model

class SynchronisationModelHandler extends UMLModelHandler {
	
	protected static Map<Model, BidirectionalSynchronization> runningSynchronizations = newHashMap
	
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
			
			project.startTransformation(model)
			
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
	
	override protected startTransformation(IProject project, Model model) {
		val javaProject = JavaCore.create(project);
		val umlTransformation = new JDTUMLTransformation()
		val transformation = new UMLToJavaTransformation(javaProject, model)
		val synch = new BidirectionalSynchronization(umlTransformation, transformation)
		
		synch.allowJava2UML
		
		println('''Starting Java2UML Transformation «javaProject.elementName»'''.toString)
		umlTransformation.start(javaProject, model)
		
		println('''Starting UML2Java Transformation «javaProject.elementName»'''.toString)
		transformation.initialize()
		transformation.execute
		
		
		
		runningSynchronizations.put(model, synch)
	}
	
}
