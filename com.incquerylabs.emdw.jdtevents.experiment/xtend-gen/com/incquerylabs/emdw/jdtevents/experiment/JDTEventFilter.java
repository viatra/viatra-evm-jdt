package com.incquerylabs.emdw.jdtevents.experiment;

import org.eclipse.incquery.runtime.evm.api.event.EventFilter;
import org.eclipse.jdt.core.IJavaElementDelta;

@SuppressWarnings("all")
public class JDTEventFilter implements EventFilter<IJavaElementDelta> {
  public JDTEventFilter() {
  }
  
  @Override
  public boolean isProcessable(final IJavaElementDelta eventAtom) {
    return true;
  }
}
