package com.incquerylabs.evm.jdt.jdtmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.IJDTElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.jdtmanipulator.IJDTManipulator
import com.incquerylabs.evm.jdt.jdtmanipulator.Visibility
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaModel
import org.eclipse.jdt.core.IJavaProject

class JDTManipulator implements IJDTManipulator {

	// TODO: move this to a common config
	static val GENERATION_FOLDER = "src" 

	static val ASSOCIATION_REQUIRES_QUALIFIED_NAME = "Association name must be a qualified name. Provider: {%s}"

	IJavaProject rootProject
	IJDTElementLocator elementLocator

	new(IJDTElementLocator elementLocator) {
		this.rootProject = elementLocator.javaProject
		this.elementLocator = elementLocator
	}

	override def createClass(QualifiedName qualifiedName) {
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val packageName = qualifiedName.parent.map[toString].orElse("")

		val package = packageRoot.createPackageFragment(packageName, false, new NullProgressMonitor)
		package.createCompilationUnit(qualifiedName.name + ".java", getClassBody(packageName, qualifiedName.name), false, new NullProgressMonitor)
	}
	
	private def getClassBody(String packageName, String className) {
		'''«IF packageName != ""»package «packageName»;«ENDIF»
		
		public class «className» {
			
		}		
		'''.toString
	}

	override def createField(QualifiedName containerName, String fieldName, QualifiedName type) {
		elementLocator.locateClass(containerName).createField('''«type.toString» «fieldName»;''', null, false, new NullProgressMonitor)
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

	override changeMethodVisibility(QualifiedName qualifiedName, Visibility visibility) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeClassAbstract(QualifiedName qualifiedName, boolean isAbstract) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeMethodAbstract(QualifiedName qualifiedName, boolean isAbstract) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeFieldFinal(QualifiedName qualifiedName, boolean isFinal) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeMethodFinal(QualifiedName qualifiedName, boolean isFinal) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeFieldVisibility(QualifiedName qualifiedName, Visibility visibility) {
	}

	override changePackageName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeClassName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeFieldName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override changeMethodName(QualifiedName oldQualifiedName, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	private def deleteJavaElement(IJavaElement javaElement) {
		val javaModel = javaElement.javaModel as IJavaModel
		javaModel.delete(#[javaElement], true, new NullProgressMonitor)
	}

//	private def createRecordingASTRoot(ICompilationUnit cu) {
//		val parser = ASTParser.newParser(AST.JLS8)
//		parser.source = cu
//		val astRoot = parser.createAST(new NullProgressMonitor) as CompilationUnit
//
//		astRoot.recordModifications
//
//		return astRoot
//	}

//	private def toJDTQualifiedName(QualifiedName qn, AST ast) {
//		qn.toList.reverse.fold(null) [ seed, it |
//			if (seed == null)
//				return ast.newSimpleName(it)
//			else
//				ast.newQualifiedName(seed, ast.newSimpleName(it))
//		]
//	}

//	private def saveToCompilationUnit(CompilationUnit astCompilationUnit, ICompilationUnit jmCompilationUnit) {
//	}

}