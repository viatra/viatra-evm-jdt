package com.incquerylabs.evm.jdt.fqnutil

import java.util.Iterator
import java.util.Optional

abstract class QualifiedName implements Iterable<String> {
	
	protected val String name
	protected val Optional<? extends QualifiedName> parent
	
	protected new(String qualifiedName, QualifiedName parent) {
		this.name = qualifiedName
		this.parent = Optional::ofNullable(parent)
	}
	
	def getName() {
		return name
	}
	
	def getParent() {
		return parent
	}

	override iterator() {
		return new QualifiedNameIterator(this)
	}

	override toString() {
		val builder = new StringBuilder()
		parent.ifPresent[
			builder.append(it.toString).append(separator)
		]
		return builder.append(name).toString		 
	}
	
	abstract def String getSeparator()
	
	private static class QualifiedNameIterator implements Iterator<String> {
		
		QualifiedName current
		
		new (QualifiedName current) {
			this.current = current
		}
		
		override hasNext() {
			return current != null
		}
		
		override next() {
			val name = current.name
			
			current = current.parent.orElse(null)
			
			return name
		}
		
	}
	
	override equals(Object obj) {
		if(obj instanceof QualifiedName) {
			return this.toString.equals(obj.toString)
		}
		return false
	}
	
}
