package com.incquerylabs.evm.jdt.umlmanipulator.impl

import com.incquerylabs.evm.jdt.fqnutil.QualifiedName
import com.incquerylabs.evm.jdt.umlmanipulator.IUMLManipulator
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain

class TransactionalManipulator implements IUMLManipulator {
	val IUMLManipulator manipulator
	val TransactionalEditingDomain domain
	
	new(IUMLManipulator manipulator, TransactionalEditingDomain domain) {
		this.manipulator = manipulator
		this.domain = domain
	}
	
	override createClass(QualifiedName fqn) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.createClass(fqn)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override updateName(QualifiedName fqn) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.updateName(fqn)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override deleteClass(QualifiedName fqn) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.deleteClass(fqn)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override createAssociation(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.createAssociation(fqn, typeQualifiedName)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override deleteAssociation(QualifiedName fqn) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.deleteAssociation(fqn)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override updateType(QualifiedName fqn, QualifiedName typeQualifiedName) {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.updateType(fqn, typeQualifiedName)
			}
		}
		domain.commandStack.execute(command)
	}
	
	override save() {
		val command = new RecordingCommand(domain) {
			override protected doExecute() {
				manipulator.save
			}
		}
		domain.commandStack.execute(command)
	}
}
