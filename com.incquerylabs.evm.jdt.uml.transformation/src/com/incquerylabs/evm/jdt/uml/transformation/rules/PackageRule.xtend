package com.incquerylabs.evm.jdt.uml.transformation.rules

import com.incquerylabs.evm.jdt.JDTActivationState
import com.incquerylabs.evm.jdt.JDTEventSourceSpecification
import com.incquerylabs.evm.jdt.JDTRule
import com.incquerylabs.evm.jdt.fqnutil.JDTQualifiedName
import com.incquerylabs.evm.jdt.uml.transformation.rules.filters.PackageFragmentFilter
import com.incquerylabs.evm.jdt.umlmanipulator.UMLModelAccess
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle
import org.eclipse.incquery.runtime.evm.specific.Jobs
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import com.incquerylabs.evm.jdt.job.JDTJobFactory

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
				umlPackage.ifPresent[
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