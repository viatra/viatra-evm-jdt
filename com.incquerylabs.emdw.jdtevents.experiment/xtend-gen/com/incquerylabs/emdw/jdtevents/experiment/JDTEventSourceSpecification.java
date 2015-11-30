package com.incquerylabs.emdw.jdtevents.experiment;

import com.incquerylabs.emdw.jdtevents.experiment.JDTEventFilter;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventHandler;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSource;
import com.incquerylabs.emdw.jdtevents.experiment.JDTRealm;
import org.eclipse.incquery.runtime.evm.api.RuleInstance;
import org.eclipse.incquery.runtime.evm.api.event.AbstractRuleInstanceBuilder;
import org.eclipse.incquery.runtime.evm.api.event.EventFilter;
import org.eclipse.incquery.runtime.evm.api.event.EventRealm;
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification;
import org.eclipse.jdt.core.IJavaElementDelta;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;

@SuppressWarnings("all")
public class JDTEventSourceSpecification implements EventSourceSpecification<IJavaElementDelta> {
  @Override
  public EventFilter<IJavaElementDelta> createEmptyFilter() {
    return new JDTEventFilter();
  }
  
  @Override
  public AbstractRuleInstanceBuilder<IJavaElementDelta> getRuleInstanceBuilder(final EventRealm realm) {
    final Procedure2<RuleInstance<IJavaElementDelta>, EventFilter<? super IJavaElementDelta>> _function = (RuleInstance<IJavaElementDelta> ruleInstance, EventFilter<? super IJavaElementDelta> filter) -> {
      JDTEventSource source = new JDTEventSource(this, ((JDTRealm) realm));
      JDTEventHandler handler = new JDTEventHandler(source, ((JDTEventFilter) filter), ruleInstance);
      source.addHandler(handler);
    };
    return ((AbstractRuleInstanceBuilder<IJavaElementDelta>) new AbstractRuleInstanceBuilder<IJavaElementDelta>() {
        public void prepareRuleInstance(RuleInstance<IJavaElementDelta> ruleInstance, EventFilter<? super IJavaElementDelta> filter) {
          _function.apply(ruleInstance, filter);
        }
    });
  }
}
