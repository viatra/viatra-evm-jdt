package com.incquerylabs.emdw.jdtevents.experiment;

import com.google.common.collect.Sets;
import com.incquerylabs.emdw.jdtevents.experiment.JDTEventSource;
import java.util.Set;
import org.eclipse.incquery.runtime.evm.api.event.EventRealm;
import org.eclipse.jdt.core.IJavaElementDelta;

@SuppressWarnings("all")
public class JDTRealm implements EventRealm {
  private Set<JDTEventSource> sources = Sets.<JDTEventSource>newHashSet();
  
  public JDTRealm() {
  }
  
  public void pushChange(final IJavaElementDelta delta) {
    for (final JDTEventSource source : this.sources) {
      source.pushChange(delta);
    }
  }
  
  protected void addSource(final JDTEventSource source) {
    this.sources.add(source);
  }
}
