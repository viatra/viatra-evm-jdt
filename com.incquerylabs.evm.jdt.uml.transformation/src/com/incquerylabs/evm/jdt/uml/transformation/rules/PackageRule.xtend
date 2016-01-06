package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.job.JDTJobFactory
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.PackageFragmentFilter
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.specific.Jobs
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment

class PackageRule extends JDTRule {
	extension Logger logger = Logger.getLogger(this.class)
	extension val IUMLManipulator umlManipulator
	
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, IUMLManipulator umlManipulator) {
		super(eventSourceSpecification, activationLifeCycle, project)
		this.umlManipulator = umlManipulator
		this.filter = new PackageFragmentFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(Jobs.newEnableJob(JDTJobFactory.createJob(JDTActivationState.APPEARED)[activation, context |
			val atom = activation.atom
			val packageFragment = atom.element as IPackageFragment
			val fqn = JDTQualifiedName::create(packageFragment.elementName)
			umlManipulator.createPackage(fqn)
			debug('''Package appeared: «atom.element»''')
		]))
		
		jobs.add(Jobs.newEnableJob(JDTJobFactory.createJob(JDTActivationState.DISAPPEARED)[activation, context |
			try {
				val packageFragment = activation.atom.element as IPackageFragment
				val fqn = JDTQualifiedName::create(packageFragment.elementName)
				umlManipulator.deletePackage(fqn)
				debug('''Package disappeared: «packageFragment»''')
			} catch (IllegalArgumentException e) {
				error('''Error during updating package''', e)
			}
		]))
		
		jobs.add(Jobs.newEnableJob(JDTJobFactory.createJob(JDTActivationState.UPDATED)[activation, context |
			val atom = activation.atom
			debug('''Package updated: «atom.element»''')
		]))
	}
	
}