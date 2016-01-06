package com.incquerylabs.evm.jdt.ui

import com.incquerylabs.evm.jdt.java.transformation.UMLToJavaTransformation
import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.uml2.uml.Model

class UMLToJavaSynchronizationHandler extends UMLModelHandler {
	
	override protected startTransformation(IProject project, Model model) {
		val javaProject = JavaCore::create(project)
		println('''Working on project «javaProject.elementName»'''.toString)
		val transformation = new UMLToJavaTransformation(javaProject, model)
		transformation.initialize()
		transformation.enableSynchronization
		transformation.execute
	}
	
}