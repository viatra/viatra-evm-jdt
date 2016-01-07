package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.common.queries.UmlQueries
import com.incquerylabs.evm.jdt.fqnutil.IUMLElementLocator
import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.fqnutil.UMLQualifiedName
import com.incquerylabs.evm.jdt.fqnutil.impl.UMLElementLocator
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.api.IncQueryEngine
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Property
import org.eclipse.uml2.uml.Type
import org.eclipse.uml2.uml.TypedElement
import org.eclipse.uml2.uml.UMLFactory

class UMLManipulator implements IUMLManipulator {
	extension val Logger logger = Logger.getLogger(this.class)
	extension val UMLFactory umlFactory = UMLFactory.eINSTANCE
	val Model model
	val IUMLElementLocator locator
	static val umlQueries = UmlQueries::instance
	val IncQueryEngine engine
	
	
	new(Model umlModel, IncQueryEngine engine) {
		this.model = umlModel
		this.engine = engine
		this.locator = new UMLElementLocator(umlModel, engine)
		logger.level = Level.DEBUG
	}
	
	override createClass(QualifiedName fqn) {
		val umlFqn = UMLQualifiedName::create(fqn)
		val umlClass = createClass => [
			name = umlFqn.name
		]
		if(umlFqn.parent.isPresent){
			val parent = locator.locateElement(umlFqn.parent.get)
			if(parent != null) {
				if(parent instanceof Package) {
					parent.packagedElements += umlClass
					debug('''Created class «umlFqn»''')
				}
			}
		}
	}
	
	override updateName(QualifiedName fqn) {
		val umlElement = locator.locateElement(fqn)
		if(umlElement != null) {
			umlElement.name = fqn.name
			debug('''Updated name of «fqn»''')
		}
	}
	
	override deleteClass(QualifiedName fqn) {
		val umlClass = locator.locateElement(fqn)
		if(umlClass != null) {
			umlClass.destroy
			debug('''Deleted class «fqn»''')
		}
	}
	
	override createAssociation(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val parentQualifiedName = UMLQualifiedName::create(fqn.parent.get)
		val umlTypeQualifiedName = UMLQualifiedName::create(typeQualifiedName)
		
		val parentClass = locator.locateElement(parentQualifiedName)
		if(parentClass != null) {
			if(parentClass instanceof Class) {
				val association = createAssociation => [
					it.name = '''«parentClass.name»_«fqn.name»'''
				]
				val navigableEnd = createProperty => [
					it.name = fqn.name
					it.association = association
					it.type = locator.locateElement(umlTypeQualifiedName) as Type
				]
				val oppositeEnd = createProperty => [
					it.name = '''«fqn.name»_opposite'''
					it.association = association
					it.type = parentClass
				]
				association.ownedEnds += navigableEnd
				association.ownedEnds += oppositeEnd
				association.navigableOwnedEnds += navigableEnd
				parentClass.package.packagedElements += association
				
				debug('''Created association «fqn» with type «typeQualifiedName»''')
			}
		}
	}
	
	override updateType(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val typedElement = locator.locateElement(fqn)
		if(typedElement instanceof TypedElement) {
			val type = locator.locateElement(typeQualifiedName) as Class
			typedElement.type = type
			trace('''Updated type of «fqn» to «typeQualifiedName»''')
		}
	}
	
	override deleteAssociation(QualifiedName fqn) {
		val memberEnd = locator.locateElement(fqn)
		if(memberEnd instanceof Property) {
			val association = memberEnd.association
			if(association != null) {
				association.memberEnds.forEach[destroy]
				association.destroy
				debug('''Deleted association «fqn»''')
			}
		}
	}
	
	override deleteClassAndReferences(QualifiedName fqn) {
		val umlClass = locator.locateElement(fqn)
		if(umlClass != null) {
			if(umlClass instanceof Class){
				umlClass.deleteAssociationsOfClass
				umlClass.destroy
				debug('''Deleted class «fqn»''')
			}
		}
	}
	
	override deleteReferencesOfClass(QualifiedName fqn) {
		val umlClass = locator.locateElement(fqn)
		if(umlClass != null) {
			if(umlClass instanceof Class){
				umlClass.deleteAssociationsOfClass
				debug('''Deleted references of class «fqn»''')
			}
		}
	}
	
	override createPackage(QualifiedName fqn) {
		if(!fqn.parent.isPresent) {
			throw new IllegalArgumentException("Cannot create root package")
		}
		val parentFqn = fqn.parent.get
		
		val packageFragment = umlFactory.createPackage() => [
			name = fqn.name
		]
		val parentPackage =  locator.locateElement(parentFqn)
		if(parentPackage instanceof Package) {
			parentPackage.packagedElements += packageFragment
			debug('''Created package «fqn»''')
		} else {
			throw new IllegalArgumentException("Package must be in another package")
		}
		
	}
	
	override deletePackage(QualifiedName fqn) {
		val packageFragment = locator.locateElement(fqn)
		if(packageFragment != null) {
			if(packageFragment instanceof Package){
				packageFragment.destroy
				debug('''Deleted package «fqn»''')
			}
		}
	}
	
	override save() {
		model.eResource.save(null)
		debug('''Saved UML resource''')
	}

	private def deleteAssociationsOfClass(Class umlClass) {
		val matcher = umlQueries.associationOfClass.getMatcher(engine)
		val associations = matcher.getAllValuesOfassociation(null, umlClass.qualifiedName, null, null)
		associations.forEach[association | 
			association.memberEnds.forEach[ memberEnd|
				memberEnd.destroy
			]
			association.destroy
		]
	}
	
	
}
