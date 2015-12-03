package com.incquerylabs.evm.jdt

import org.eclipse.incquery.runtime.evm.api.RuleSpecification
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.jdt.core.IJavaElement

@Data
class JDTRule {
	RuleSpecification<IJavaElement> ruleSpecification
	JDTEventFilter filter
}