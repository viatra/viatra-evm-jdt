package com.incquerylabs.emdw.jdtevents.experiment;

import com.incquerylabs.emdw.jdtevents.experiment.JDTEventFilter;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSource;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventType;
import org.eclipse.incquery.runtime.evm.api.Activation;
import org.eclipse.incquery.runtime.evm.api.RuleInstance;
import org.eclipse.incquery.runtime.evm.api.event.Event;
import org.eclipse.incquery.runtime.evm.api.event.EventFilter;
import org.eclipse.incquery.runtime.evm.api.event.EventHandler;
import org.eclipse.incquery.runtime.evm.api.event.EventSource;
import org.eclipse.incquery.runtime.evm.api.event.EventType;
import org.eclipse.jdt.core.IJavaElementDelta;

@SuppressWarnings("all")
public class JDTEventHandler implements EventHandler<IJavaElementDelta> {
  private JDTEventFilter filter;
  
  private JDTEventSource source;
  
  private RuleInstance<IJavaElementDelta> instance;
  
  @Override
  public void handleEvent(final Event<IJavaElementDelta> event) {
    EventType _eventType = event.getEventType();
    JDTEventType type = ((JDTEventType) _eventType);
    IJavaElementDelta eventAtom = event.getEventAtom();
    if (type != null) {
      switch (type) {
        case ELEMENT_CHANGED:
          Activation<IJavaElementDelta> activation = this.instance.createActivation(eventAtom);
          this.instance.activationStateTransition(activation, type);
          break;
        default:
          System.err.println("Something bad happened");
          break;
      }
    } else {
      System.err.println("Something bad happened");
    }
  }
  
  @Override
  public EventSource<IJavaElementDelta> getSource() {
    return this.source;
  }
  
  @Override
  public EventFilter<? super IJavaElementDelta> getEventFilter() {
    return this.filter;
  }
  
  @Override
  public void dispose() {
  }
  
  /**
   * @param source
   * @param filter
   * @param instance
   */
  public JDTEventHandler(final JDTEventSource source, final JDTEventFilter filter, final RuleInstance<IJavaElementDelta> instance) {
    this.source = source;
    this.filter = filter;
    this.instance = instance;
  }
}
