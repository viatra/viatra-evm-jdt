package com.incquerylabs.evm.jdt.jdtmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.IJDTElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.jdtmanipulator.IJDTManipulator
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaModel
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.dom.CompilationUnit
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.jface.text.Document

class JDTManipulator implements IJDTManipulator {

	// TODO: move this to a common config
	static val GENERATION_FOLDER = "src" 

	IJavaProject rootProject
	IJDTElementLocator elementLocator

	new(IJDTElementLocator elementLocator) {
		this.rootProject = elementLocator.javaProject
		this.elementLocator = elementLocator
	}

	override def createClass(QualifiedName qualifiedName) {
		val clazz = elementLocator.locateClass(qualifiedName)
		if(clazz != null)
			return clazz
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val packageName = qualifiedName.parent.map[toString].orElse("")

		val package = packageRoot.createPackageFragment(packageName, false, new NullProgressMonitor)
		val cu = package.createCompilationUnit(qualifiedName.name + ".java", getClassBody(packageName, qualifiedName.name), false, new NullProgressMonitor)
		return cu.types.head
	}
	
	private def getClassBody(String packageName, String className) {
		'''
		«IF packageName != ""»package «packageName»;«ENDIF»
		
		public class «className» {
			
		}
		'''.toString
	}

	override def createField(QualifiedName containerName, String fieldName, QualifiedName type) {
		val clazz = elementLocator.locateClass(containerName)
		val field = clazz.fields.findFirst[it.elementName == fieldName]
		if(field != null) {
			return field
		}
		return clazz.createField('''«type.toString» «fieldName»;''', null, false, new NullProgressMonitor)
	}

	override createPackage(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override createMethod(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override deletePackage(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override deleteClass(QualifiedName qualifiedName) {
		elementLocator.locateClass(qualifiedName).compilationUnit.deleteJavaElement
	}

	override deleteField(QualifiedName qualifiedName) {
		elementLocator.locateFieldNode(qualifiedName).deleteJavaElement
	}

	override deleteMethod(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changePackageName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override updateClass(QualifiedName oldQualifiedName, String name) {
		val clazz = elementLocator.locateClass(oldQualifiedName)
		clazz.rename(name, true, new NullProgressMonitor)
	}

	override updateField(QualifiedName oldQualifiedName, QualifiedName type, String name) {
		val field = elementLocator.locateFieldNode(oldQualifiedName)
		
		val astRoot = field.compilationUnit.createRecordingASTRoot
		astRoot.accept(new ASTVisitor {
			
			override visit(FieldDeclaration node) {
				val varDeclaration = node.fragments.head as VariableDeclarationFragment
				if(varDeclaration.name.toString.equals(oldQualifiedName.name)) {
					varDeclaration.name = node.AST.newSimpleName(name)
					node.type = node.AST.newSimpleType(type.toJDTQualifiedName(node.AST))
				}
				
				return false;
			}
			
		})
		
		astRoot.saveToCompilationUnit(field.compilationUnit)
	}

	override changeMethodName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	private def deleteJavaElement(IJavaElement javaElement) {
		val javaModel = javaElement.javaModel as IJavaModel
		javaModel.delete(#[javaElement], true, new NullProgressMonitor)
	}

	private def createRecordingASTRoot(ICompilationUnit cu) {
		val parser = ASTParser.newParser(AST.JLS8)
		parser.source = cu
		val astRoot = parser.createAST(new NullProgressMonitor) as CompilationUnit

		astRoot.recordModifications

		return astRoot
	}

	private def toJDTQualifiedName(QualifiedName qn, AST ast) {
		qn.toList.reverse.fold(null) [ seed, it |
			if (seed == null)
				return ast.newSimpleName(it)
			else
				ast.newQualifiedName(seed, ast.newSimpleName(it))
		]
	}

	private def saveToCompilationUnit(CompilationUnit astCompilationUnit, ICompilationUnit jmCompilationUnit) {
		val document = new Document(jmCompilationUnit.source)
		val edits = astCompilationUnit.rewrite(document, jmCompilationUnit.javaProject.getOptions(true))
		edits.apply(document)
		jmCompilationUnit.buffer.contents = document.get
		jmCompilationUnit.save(new NullProgressMonitor, true)
	}
	
}