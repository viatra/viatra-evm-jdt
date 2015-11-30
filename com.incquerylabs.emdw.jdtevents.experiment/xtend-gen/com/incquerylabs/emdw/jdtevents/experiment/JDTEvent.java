package com.incquerylabs.emdw.jdtevents.experiment;

import com.incquerylabs.emdw.jdtevents.experiment.JDTEventType;
import org.eclipse.incquery.runtime.evm.api.event.Event;
import org.eclipse.incquery.runtime.evm.api.event.EventType;
import org.eclipse.jdt.core.IJavaElementDelta;

@SuppressWarnings("all")
public class JDTEvent implements Event<IJavaElementDelta> {
  private JDTEventType type;
  
  /**
   * @param type
   * @param atom
   */
  public JDTEvent(final JDTEventType type, final IJavaElementDelta atom) {
    this.type = type;
    this.atom = atom;
  }
  
  private IJavaElementDelta atom;
  
  @Override
  public EventType getEventType() {
    return this.type;
  }
  
  @Override
  public IJavaElementDelta getEventAtom() {
    return this.atom;
  }
}
