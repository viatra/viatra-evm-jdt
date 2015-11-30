package com.incquerylabs.emdw.jdtevents.experimentapp;

import com.google.common.collect.Sets;
import com.incquerylabs.emdw.jdtevents.experiment.JDTActivationState;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventFilter;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSourceSpecification;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventType;
import com.incquerylabs.emdw.jdtevents.experiment.JDTRealm;
import com.incquerylabs.emdw.jdtutil.ChangeFlag;
import com.incquerylabs.emdw.jdtutil.JDTChangeFlagDecoder;
import java.util.Arrays;
import java.util.HashSet;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.eclipse.incquery.runtime.evm.api.Activation;
import org.eclipse.incquery.runtime.evm.api.ActivationLifeCycle;
import org.eclipse.incquery.runtime.evm.api.Context;
import org.eclipse.incquery.runtime.evm.api.EventDrivenVM;
import org.eclipse.incquery.runtime.evm.api.Job;
import org.eclipse.incquery.runtime.evm.api.RuleEngine;
import org.eclipse.incquery.runtime.evm.api.RuleSpecification;
import org.eclipse.incquery.runtime.evm.api.event.EventFilter;
import org.eclipse.incquery.runtime.evm.api.event.EventType;
import org.eclipse.jdt.core.IJavaElementDelta;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.xtend2.lib.StringConcatenation;

@SuppressWarnings("all")
public class JDTEventDrivenApp {
  private final RuleEngine engine;
  
  /**
   * @param jdtRealm
   */
  public JDTEventDrivenApp(final JDTRealm jdtRealm) {
    RuleEngine _createRuleEngine = EventDrivenVM.createRuleEngine(jdtRealm);
    this.engine = _createRuleEngine;
  }
  
  public void start() {
    Logger _logger = this.engine.getLogger();
    _logger.setLevel(Level.DEBUG);
    final ActivationLifeCycle lifeCycle = ActivationLifeCycle.create(JDTActivationState.INACTIVE);
    lifeCycle.addStateTransition(JDTActivationState.INACTIVE, JDTEventType.ELEMENT_CHANGED, 
      JDTActivationState.ACTIVE);
    lifeCycle.addStateTransition(JDTActivationState.ACTIVE, EventType.RuleEngineEventType.FIRE, 
      JDTActivationState.INACTIVE);
    final Job<IJavaElementDelta> job = new Job<IJavaElementDelta>(JDTActivationState.ACTIVE) {
      @Override
      protected void execute(final Activation<? extends IJavaElementDelta> activation, final Context context) {
        final IJavaElementDelta delta = activation.getAtom();
        System.out.println("********** An element has changed **********");
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Delta: ");
        String _string = delta.toString();
        _builder.append(_string, "");
        System.out.println(_builder);
        StringConcatenation _builder_1 = new StringConcatenation();
        _builder_1.append("Affected children: ");
        IJavaElementDelta[] _affectedChildren = delta.getAffectedChildren();
        String _string_1 = Arrays.toString(_affectedChildren);
        _builder_1.append(_string_1, "");
        System.out.println(_builder_1);
        StringConcatenation _builder_2 = new StringConcatenation();
        _builder_2.append("AST: ");
        CompilationUnit _compilationUnitAST = delta.getCompilationUnitAST();
        _builder_2.append(_compilationUnitAST, "");
        System.out.println(_builder_2);
        StringConcatenation _builder_3 = new StringConcatenation();
        _builder_3.append("Change flags: ");
        int _flags = delta.getFlags();
        HashSet<ChangeFlag> _changeFlags = JDTChangeFlagDecoder.toChangeFlags(_flags);
        _builder_3.append(_changeFlags, "");
        System.out.println(_builder_3);
        System.out.println("********************************************");
      }
      
      @Override
      protected void handleError(final Activation<? extends IJavaElementDelta> activation, final Exception exception, final Context context) {
      }
    };
    final JDTEventSourceSpecification sourceSpec = new JDTEventSourceSpecification();
    HashSet<Job<IJavaElementDelta>> _newHashSet = Sets.<Job<IJavaElementDelta>>newHashSet(job);
    final RuleSpecification<IJavaElementDelta> ruleSpec = new RuleSpecification<IJavaElementDelta>(sourceSpec, lifeCycle, _newHashSet);
    EventFilter<IJavaElementDelta> _createEmptyFilter = sourceSpec.createEmptyFilter();
    final JDTEventFilter filter = ((JDTEventFilter) _createEmptyFilter);
    this.engine.<IJavaElementDelta>addRule(ruleSpec, filter);
  }
  
  public void fire() {
    Activation<?> _nextActivation = this.engine.getNextActivation();
    Context _create = Context.create();
    _nextActivation.fire(_create);
  }
}
