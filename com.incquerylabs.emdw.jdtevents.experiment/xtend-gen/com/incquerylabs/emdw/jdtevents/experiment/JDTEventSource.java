package com.incquerylabs.emdw.jdtevents.experiment;

import com.google.common.collect.Sets;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEvent;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventHandler;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSourceSpecification;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventType;
import com.incquerylabs.emdw.jdtevents.experiment.JDTRealm;
import java.util.Set;
import org.eclipse.incquery.runtime.evm.api.event.EventRealm;
import org.eclipse.incquery.runtime.evm.api.event.EventSource;
import org.eclipse.incquery.runtime.evm.api.event.EventSourceSpecification;
import org.eclipse.jdt.core.IJavaElementDelta;

@SuppressWarnings("all")
public class JDTEventSource implements EventSource<IJavaElementDelta> {
  private JDTEventSourceSpecification spec;
  
  private JDTRealm realm;
  
  private Set<JDTEventHandler> handlers = Sets.<JDTEventHandler>newHashSet();
  
  @Override
  public EventSourceSpecification<IJavaElementDelta> getSourceSpecification() {
    return this.spec;
  }
  
  @Override
  public EventRealm getRealm() {
    return this.realm;
  }
  
  @Override
  public void dispose() {
  }
  
  public void pushChange(final IJavaElementDelta delta) {
    JDTEvent event = new JDTEvent(JDTEventType.ELEMENT_CHANGED, delta);
    for (final JDTEventHandler handler : this.handlers) {
      handler.handleEvent(event);
    }
  }
  
  protected void addHandler(final JDTEventHandler handler) {
    this.handlers.add(handler);
  }
  
  public JDTEventSource(final JDTEventSourceSpecification spec, final JDTRealm realm) {
    this.spec = spec;
    this.realm = realm;
    realm.addSource(this);
  }
}
