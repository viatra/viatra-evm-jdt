package com.incquerylabs.evm.jdt.jdtmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.IJDTElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.jdtmanipulator.IJDTManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jdt.core.ICompilationUnit
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaModel
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.dom.AST
import org.eclipse.jdt.core.dom.ASTParser
import org.eclipse.jdt.core.dom.ASTVisitor
import org.eclipse.jdt.core.dom.CompilationUnit
import org.eclipse.jdt.core.dom.FieldDeclaration
import org.eclipse.jdt.core.dom.VariableDeclarationFragment
import org.eclipse.jface.text.Document

class JDTManipulator implements IJDTManipulator {

	extension val Logger logger = Logger.getLogger(this.class)

	// TODO: move this to a common config
	static val GENERATION_FOLDER = "src" 

	IJavaProject rootProject
	IJDTElementLocator elementLocator

	new(IJDTElementLocator elementLocator) {
		this.rootProject = elementLocator.javaProject
		this.elementLocator = elementLocator
		logger.level = Level.DEBUG
	}

	override def createClass(QualifiedName qualifiedName) {
		val clazz = elementLocator.locateClass(qualifiedName)
		if(clazz != null) {
			debug('''Class <«clazz.fullyQualifiedName»> already exists''')
			return clazz
		}
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val packageName = qualifiedName.parent.map[toString].orElse("")

		val package = packageRoot.createPackageFragment(packageName, false, new NullProgressMonitor)
		val className = qualifiedName.name
		val compilationUnitName = '''«className».java'''
		return (package.createCompilationUnit(compilationUnitName, getClassBody(packageName, className), false, new NullProgressMonitor) => [
			debug('''Created class <«className»> in package <«packageName»> in file <«compilationUnitName»>''')
		]).types.head
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
			debug('''Field <«field.elementName»> in <«clazz.fullyQualifiedName»> already exists''')
			return field
		}
		return clazz.createField('''«type.toString» «fieldName»;''', null, false, new NullProgressMonitor) => [
			debug('''Created field <«fieldName»> in class <«clazz.fullyQualifiedName»>''')		
		]
	}

	override createPackage(QualifiedName qualifiedName) {
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val existingPackage = packageRoot.getPackageFragment(qualifiedName.toString)
		if(existingPackage.exists) {
			debug('''Package <«existingPackage.elementName»> already exists''')
			return existingPackage
		}
		
		return packageRoot.createPackageFragment(qualifiedName.toString, false, new NullProgressMonitor) => [
			debug('''Created package <«qualifiedName»>''')
		]
	}

	override createMethod(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override deletePackage(QualifiedName qualifiedName) {
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val existingPackage = packageRoot.getPackageFragment(qualifiedName.toString)
		if(!existingPackage.exists) {
			error('''Package <«qualifiedName»> cannot be deleted, does not exist''')
			return
		}
		
		debug('''Deleting package <«existingPackage.elementName»> ''')
		existingPackage.deleteJavaElement		
	}

	override deleteClass(QualifiedName qualifiedName) {
		val clazz = elementLocator.locateClass(qualifiedName)
		debug('''Deleting class <«clazz.fullyQualifiedName»>''')
		clazz.compilationUnit.deleteJavaElement		
	}

	override deleteField(QualifiedName qualifiedName) {
		val field = elementLocator.locateFieldNode(qualifiedName)
		debug('''Deleting field <«field.elementName»> in class <«field.declaringType.fullyQualifiedName»>''')
		field.deleteJavaElement
	}

	override deleteMethod(QualifiedName qualifiedName) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override updatePackage(QualifiedName oldQualifiedName, QualifiedName newQualifiedName) {
		val genFolder = rootProject.project.getFolder(GENERATION_FOLDER)
		val packageRoot = rootProject.getPackageFragmentRoot(genFolder)
		val existingPackage = packageRoot.getPackageFragment(oldQualifiedName.toString)
		if(!existingPackage.exists) {
			error('''Package <«oldQualifiedName»> cannot be renamed, does not exist''')
			return
		}
		
		debug('''Renaming package <«existingPackage.elementName»> to <«newQualifiedName.toString»>''')
		existingPackage.rename(newQualifiedName.toString, false, new NullProgressMonitor)
	}

	override updateClass(QualifiedName oldQualifiedName, String name) {
		val clazz = elementLocator.locateClass(oldQualifiedName)
		debug('''Renaming class <«clazz.fullyQualifiedName»> to <«name»>''')
		clazz.rename(name, true, new NullProgressMonitor)
	}

	override updateField(QualifiedName oldQualifiedName, QualifiedName type, String name) {
		val field = elementLocator.locateFieldNode(oldQualifiedName)
		
		val astRoot = field.compilationUnit.createRecordingASTRoot
		astRoot.accept(new ASTVisitor {
			
			override visit(FieldDeclaration node) {
				val varDeclaration = node.fragments.head as VariableDeclarationFragment
				if(varDeclaration.name.toString.equals(oldQualifiedName.name)) {
					debug('''Updating field <«varDeclaration.name»> in class <«field.declaringType.fullyQualifiedName»> to new name <«name»>, new type <«type»>''')
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