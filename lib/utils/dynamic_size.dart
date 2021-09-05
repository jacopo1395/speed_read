import 'package:flutter/material.dart';

class DynamicSize {
  Size? _sizeCached;

  Size getSize(GlobalKey<State<StatefulWidget>> pageKey, BuildContext context) {
    // if (_sizeCached != null) {
    //   return _sizeCached!;
    // }
    if (pageKey.currentContext != null) {
      var _pageBox = pageKey.currentContext?.findRenderObject()! as RenderBox;
      var keyboard = MediaQuery.of(context).viewInsets.bottom;
      if (keyboard != 0) {
        debugPrint('keyboard');
      }
      return _sizeCached = _pageBox.size;
    }
    return Size(0, 0);
  }
}
