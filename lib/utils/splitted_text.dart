import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:speed_read/utils/utils.dart';

class SplittedText {
  List<TextSpan> getSplittedText(Size pageSize, TextSpan textSpan) {
    final _pageTexts = <String>[];
    final _pageSpans = <TextSpan>[];
    // var text = textSpan.children!.map((e) => (e as TextSpan).text).join('');
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: pageSize.width,
    );

    // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    var lines = textPainter.computeLineMetrics();
    var currentPageBottom = pageSize.height;
    var currentPageStartIndex = 0;
    var currentPageEndIndex = 0;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      final left = line.left;
      final top = line.baseline - line.ascent;
      final bottom = line.baseline + line.descent;

      // Current line overflow page
      if (currentPageBottom < bottom) {
        // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top)).offset;
        // final pageText =
        //     text.substring(currentPageStartIndex, currentPageEndIndex);
        // _pageTexts.add(pageText);
        var _paragraph = TextSpan(children: []);

        var countLetter = 0;
        textSpan.children!.forEach((element) {
          if (countLetter >= currentPageStartIndex &&
              countLetter < currentPageEndIndex) {
            _paragraph.children!.add(element as TextSpan);
          }
          countLetter += (element as TextSpan).text!.length;
        });

        _pageSpans.add(_paragraph);

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom = top + pageSize.height;
      }
    }

    // final lastPageText = text.substring(currentPageStartIndex);
    // _pageTexts.add(lastPageText);
    var countLetter = 0;
    var _paragraph = TextSpan(children: []);
    textSpan.children!.forEach((element) {
      if (countLetter >= currentPageStartIndex) {
        _paragraph.children!.add(element as TextSpan);
      }
      countLetter += (element as TextSpan).text!.length;
    });
    _pageSpans.add(_paragraph);
    return _pageSpans;
  }
}
