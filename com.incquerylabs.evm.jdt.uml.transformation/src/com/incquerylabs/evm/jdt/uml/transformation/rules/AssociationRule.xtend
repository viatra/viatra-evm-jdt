package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.jdt.core.IField
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IType
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.dom.AST
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration

class AssociationRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val IUMLManipulator umlManipulator
	
	new(
		JDTEventSourceSpecification eventSourceSpecification, 
		ActivationLifeCycle activationLifeCycle, 
		IJavaProject project, 
		IUMLManipulator umlManipulator
	) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlManipulator = umlManipulator
		logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(JDTJobFactory.createJob(JDTActivationState.APPEARED)[activation, context |
			val javaField = activation.atom.element
			if(javaField instanceof IField) {
				val parentClass = javaField.parent
				if(parentClass instanceof IType) {
					val javaQualifiedName = JDTQualifiedName::create('''«parentClass.fullyQualifiedName»::«javaField.elementName»''')
					val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
					
					val parser = ASTParser.newParser(AST.JLS8)
					parser.resolveBindings = true
					parser.source = javaField.compilationUnit
					val unitNode = parser.createAST(new NullProgressMonitor)
					
					unitNode.accept(new ASTVisitor{
						override visit(VariableDeclarationFragment node){
							val binding = node.resolveBinding
							if(binding == null) {
								return false
							}
							val element = binding.javaElement
							if(javaField == element) {
								val fieldDeclaration = node.parent as FieldDeclaration
								val type = fieldDeclaration.type.resolveBinding.javaElement as IType
								val typeJavaQualifiedName = JDTQualifiedName.create(type.fullyQualifiedName)
								val typeQualifiedName = UMLQualifiedName.create(typeJavaQualifiedName)
								createAssociation(umlQualifiedName, typeQualifiedName)
								return false
							}
							return true
						}
					})
				}
			}
		])
		
		jobs.add(JDTJobFactory.createJob(JDTActivationState.DISAPPEARED)[activation, context |
			val javaField = activation.atom.element
			if(javaField instanceof IField) {
				val parentClass = javaField.declaringType
				if(parentClass != null) {
					val javaQualifiedName = JDTQualifiedName::create('''«parentClass.fullyQualifiedName»::«javaField.elementName»''')
					val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
					deleteAssociation(umlQualifiedName)
				}
			}
		])
		
		jobs.add(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
			val javaField = activation.atom.element
			if(javaField instanceof IField) {
				val parentClass = javaField.declaringType
				if(parentClass != null) {
					val javaQualifiedName = JDTQualifiedName::create('''«parentClass.fullyQualifiedName»::«javaField.elementName»''')
					val umlQualifiedName = UMLQualifiedName::create(javaQualifiedName)
					val parser = ASTParser.newParser(AST.JLS8)
					parser.resolveBindings = true
					parser.source = javaField.compilationUnit
					val unitNode = parser.createAST(new NullProgressMonitor)
					
					unitNode.accept(new ASTVisitor{
						override visit(VariableDeclarationFragment node){
							val binding = node.resolveBinding
							if(binding == null) {
								return false
							}
							val element = binding.javaElement
							if(javaField == element) {
								val fieldDeclaration = node.parent as FieldDeclaration
								val type = fieldDeclaration.type.resolveBinding.javaElement as IType
								val typeJavaQualifiedName = JDTQualifiedName.create(type.fullyQualifiedName)
								val typeQualifiedName = UMLQualifiedName.create(typeJavaQualifiedName)
								updateType(umlQualifiedName, typeQualifiedName)
								return false
							}
							return true
						}
					})
				}
			}
		])
	}
	
}