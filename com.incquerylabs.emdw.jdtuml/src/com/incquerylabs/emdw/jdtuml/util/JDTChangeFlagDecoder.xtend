package com.incquerylabs.emdw.jdtuml.util

class JDTChangeFlagDecoder {
	public static def toChangeFlag(int value){
		ChangeFlag.values.findFirst[it.value == value]
	}
	
	public static def toChangeFlags(int values) {
		val result = newHashSet()
		ChangeFlag.values.forEach[flag | 
			if(values.bitwiseAnd(flag.value) != 0) {
				result += flag
			}
		]
		return result
	}
}
