package com.incquerylabs.emdw.jdtutil;

import com.incquerylabs.emdw.jdtutil.ChangeFlag;
import java.util.HashSet;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class JDTChangeFlagDecoder {
  public static ChangeFlag toChangeFlag(final int value) {
    ChangeFlag[] _values = ChangeFlag.values();
    final Function1<ChangeFlag, Boolean> _function = (ChangeFlag it) -> {
      int _value = it.getValue();
      return Boolean.valueOf((_value == value));
    };
    return IterableExtensions.<ChangeFlag>findFirst(((Iterable<ChangeFlag>)Conversions.doWrapArray(_values)), _function);
  }
  
  public static HashSet<ChangeFlag> toChangeFlags(final int values) {
    final HashSet<ChangeFlag> result = CollectionLiterals.<ChangeFlag>newHashSet();
    ChangeFlag[] _values = ChangeFlag.values();
    final Consumer<ChangeFlag> _function = (ChangeFlag flag) -> {
      int _value = flag.getValue();
      int _bitwiseAnd = (values & _value);
      boolean _notEquals = (_bitwiseAnd != 0);
      if (_notEquals) {
        result.add(flag);
      }
    };
    ((List<ChangeFlag>)Conversions.doWrapArray(_values)).forEach(_function);
    return result;
  }
}
