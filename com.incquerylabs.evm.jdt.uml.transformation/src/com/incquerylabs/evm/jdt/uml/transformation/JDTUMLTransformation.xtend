package com.incquerylabs.evm.jdt.uml.transformation

import com.incquerylabs.evm.jdt.JDTActivationLifeCycle
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRealm
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.uml.transformation.rules.ClassRule
import com.incquerylabs.evm.jdt.uml.transformation.rules.LoggerRule
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import com.incquerylabs.evm.jdt.umlmanipulator.impl.logger.UMLManipulationLogger
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.api.Executor
import org.eclipse.incquery.runtime.evm.api.RuleEngine
import org.eclipse.incquery.runtime.evm.api.Scheduler
import org.eclipse.incquery.runtime.evm.specific.Schedulers
import org.eclipse.jdt.core.ElementChangedEvent
import org.eclipse.jdt.core.IElementChangedListener
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.uml2.uml.Model
import com.incquerylabs.evm.jdt.umlmanipulator.impl.UMLManipulator
import com.incquerylabs.evm.jdt.uml.transformation.rules.AssociationRule

class JDTUMLTransformation {
	extension val Logger logger = Logger.getLogger(this.class)
	
	val JDTRealm jdtRealm
	val RuleEngine ruleEngine
	IUMLManipulator umlManipulator
	Executor executor
	Scheduler scheduler
	ResourceSet resourceSet = new ResourceSetImpl

	new() {
		this.jdtRealm = new JDTRealm
		this.executor = new Executor(jdtRealm)
		this.ruleEngine = RuleEngine.create(executor.ruleBase);
		this.umlManipulator = new UMLManipulationLogger
	}

	def void start(IJavaProject project) {
		ruleEngine.logger.level = Level.INFO
		logger.level = Level.DEBUG
		debug('''Transformation starting...''')
		
		val model = project.project.umlModel
		
		val ActivationLifeCycle lifeCycle = new JDTActivationLifeCycle
		val JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification
		
		umlManipulator = new UMLManipulator(model)
		
//		val loggerRule = new LoggerRule(sourceSpec, lifeCycle, project)
//		addRule(loggerRule)
		val classRule = new ClassRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(classRule)
		val associationRule = new AssociationRule(sourceSpec, lifeCycle, project, umlManipulator)
		addRule(associationRule)
		
		addJDTEventListener
		addTimedScheduler(100)
	}
	
	def addTimedScheduler(long interval) {
		val schedulerFactory = Schedulers.getTimedSchedulerFactory(interval)
		this.scheduler = schedulerFactory.prepareScheduler(executor)
	}
	
	def addRule(JDTRule rule) {
		ruleEngine.addRule(rule.ruleSpecification, rule.filter)
	}
	
	private def getUmlModel(IProject project) {
		val projectPath = project.fullPath
		val modelPath = projectPath.append("/model/model.uml")
		
		val umlUri = URI.createPlatformResourceURI(modelPath.toString, true)
		val umlResource = umlUri.getOrCreateResource
		umlResource.load(null)
		val model = umlResource.getOrCreateUmlModel
		return model
	}
	
	private def getOrCreateResource(URI resourceUri) {
		val umlResource = resourceSet.getResource(resourceUri, true)
		// TODO create UML model if it does not exist
		return umlResource
	}
	
	private def getOrCreateUmlModel(Resource umlResource) {
		val contents = umlResource.contents
		
		if(!contents.isEmpty) {
			val model = contents.filter(Model).head
			if(model!=null) {
				return model
			}
		}
		val model = UMLFactory.eINSTANCE.createModel
		contents += model
		umlResource.save(null)
		return model
	}
	
	private def addJDTEventListener() {
		JavaCore::addElementChangedListener(([ ElementChangedEvent event |
			jdtRealm.pushChange(event.delta)
		] as IElementChangedListener))
	}
}
