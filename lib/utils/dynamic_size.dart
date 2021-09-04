import 'package:flutter/material.dart';

abstract class DynamicSize {
  Size getSize(GlobalKey pagekey);
}

class DynamicSizeImpl extends DynamicSize {
  Size? _sizeCached;

  @override
  Size getSize(GlobalKey<State<StatefulWidget>> pageKey) {
    if (_sizeCached != null) {
      return _sizeCached!;
    }
    if (pageKey.currentContext != null) {
      var _pageBox = pageKey.currentContext?.findRenderObject()! as RenderBox;
      return _sizeCached = _pageBox.size;
    }
    return Size(0, 0);
  }
}
