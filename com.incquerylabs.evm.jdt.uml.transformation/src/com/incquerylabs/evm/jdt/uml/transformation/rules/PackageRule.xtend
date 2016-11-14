package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.PackageFragmentFilter
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.viatra.integration.evm.jdt.JDTActivationState
import org.eclipse.viatra.integration.evm.jdt.JDTEventSourceSpecification
import org.eclipse.viatra.integration.evm.jdt.JDTRule
import org.eclipse.viatra.integration.evm.jdt.job.JDTJobFactory
import org.eclipse.viatra.integration.evm.jdt.util.JDTQualifiedName
import org.eclipse.viatra.transformation.evm.api.ActivationLifeCycle
import org.eclipse.viatra.transformation.evm.specific.Jobs

class PackageRule extends JDTRule {
	extension val UMLModelAccess umlModelAccess
	extension Logger logger = Logger.getLogger(this.class)
	
	
	new(JDTEventSourceSpecification eventSourceSpecification, ActivationLifeCycle activationLifeCycle, IJavaProject project, UMLModelAccess umlModelAccess, JDTJobFactory jobFactory) {
		super(eventSourceSpecification, activationLifeCycle, project, jobFactory)
		this.umlModelAccess = umlModelAccess
		this.filter = new PackageFragmentFilter(this.filter)
		this.logger.level = Level.DEBUG
	}
	
	override initialize() {
		jobs.add(Jobs.newEnableJob(createJob(JDTActivationState.APPEARED)[activation, context |
			val atom = activation.atom
			val packageFragment = atom.element as IPackageFragment
			val fqn = JDTQualifiedName::create(packageFragment.elementName)
			ensurePackage(fqn)
			debug('''Package appeared: «atom.element»''')
		]))
		
		jobs.add(Jobs.newEnableJob(createJob(JDTActivationState.DISAPPEARED)[activation, context |
			try {
				val packageFragment = activation.atom.element as IPackageFragment
				val fqn = JDTQualifiedName::create(packageFragment.elementName)
				val umlPackage = findPackage(fqn)
				umlPackage.asSet.forEach[
					removePackage
				]
				debug('''Package disappeared: «packageFragment»''')
			} catch (IllegalArgumentException e) {
				error('''Error during updating package''', e)
			}
		]))
		
		jobs.add(Jobs.newEnableJob(createJob(JDTActivationState.UPDATED)[activation, context |
			val atom = activation.atom
			debug('''Package updated: «atom.element»''')
		]))
	}
	
}