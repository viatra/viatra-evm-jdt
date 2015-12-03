package com.incquerylabs.evm.jdt

import java.util.Set

interface JDTRuleProvider {
	def Set<JDTRule> getRules()
}