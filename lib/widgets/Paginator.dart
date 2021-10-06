import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/utils/tuple.dart';

class Paginator extends StatefulWidget {
  TextSpan? textSpan;
  String? text;
  Size size;
  Book book;

  Paginator(this.book, this.size);

  @override
  _PaginatorState createState() => _PaginatorState(book, size);
}

class _PaginatorState extends State<Paginator> {
  final PageController _pageController = PageController();
  PageView? pageView;
  int totalPages = 50;
  int pageIndex = 0;
  List<TextSpan> startEndPages = [];
  Size size;
  Book book;

  _PaginatorState(this.book, this.size);

  @override
  void initState() {
    super.initState();
    debugPrint('initState Paginator' + DateTime.now().toString());
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        startEndPages = getSplittedText(getPageText(pageIndex));
      });
    });
  }

  @override
  void dispose() {
    // isolate.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPageView();
  }

  Widget buildPageView() {
    var start = DateTime.now();

    var result = PageView.builder(
        controller: _pageController,
        onPageChanged: (val) {
          if (val == startEndPages.length) {
            setState(() {
              startEndPages = getSplittedText(getPageText(++pageIndex));
            });
          }
        },
        itemCount: widget.book.pages.length,
        itemBuilder: (context, index) {
          return RichText(text: startEndPages[index]);
        });
    var end = DateTime.now();

    debugPrint(
        'buildPageView:' + (end.difference(start).inMilliseconds.toString()));
    return result;
  }

  List<TextSpan> getSplittedText(TextSpan textSpan) {
    var start = DateTime.now();
    debugPrint('start splitted');
    var text = textSpan.children!.map((e) => (e as TextSpan).text).join('');

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    debugPrint('start layout');
    var size = MediaQuery.of(context).size;

    textPainter.layout(minWidth: 0, maxWidth: size.width - 16.0);

    debugPrint('start lines');
    var lines = textPainter.computeLineMetrics();
    var currentPageBottom = size.height - 250.0;
    var currentPageStartIndex = 0;
    var currentPageEndIndex = 0;

    List<TextSpan> pages = [];

    debugPrint('start for');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      final left = line.left;
      final top = line.baseline - line.ascent;
      final bottom = line.baseline + line.descent;

      // Current line overflow page
      if (currentPageBottom < bottom) {
        debugPrint('IF splitted' + i.toString());

        currentPageEndIndex =
            textPainter.getPositionForOffset(Offset(left, top)).offset;
        debugPrint('currentPageEndIndex:' + currentPageEndIndex.toString());
        debugPrint('text:' +
            text.substring(currentPageStartIndex, currentPageEndIndex));

        var _paragraph = TextSpan(children: []);

        var countLetter = 0;
        textSpan.children!.forEach((element) {
          if (countLetter >= currentPageStartIndex &&
              countLetter < currentPageEndIndex) {
            _paragraph.children!.add(element as TextSpan);
            debugPrint('countLetter:' + countLetter.toString());
          }
          countLetter += (element as TextSpan).text!.length;
        });

        pages.add(_paragraph);

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom = top + size.height - 250.0;
        debugPrint('end IF splitted');
      }
    }

    var countLetter = 0;
    var _paragraph = TextSpan(children: []);
    textSpan.children!.forEach((element) {
      if (countLetter >= currentPageStartIndex) {
        _paragraph.children!.add(element as TextSpan);
      }
      countLetter += (element as TextSpan).text!.length;
    });

    pages.add(_paragraph);

    var end = DateTime.now();
    debugPrint('splitted Text in ms:' +
        (end.difference(start).inMilliseconds.toString()));

    return pages;
  }

  TextSpan getPageText(int index) {
    var start = DateTime.now();

    var textSpan = parseMarkdown(widget.book.pages[index]);

    var end = DateTime.now();
    debugPrint('getPageText Text in ms:' +
        (end.difference(start).inMilliseconds.toString()));

    return textSpan;
  }

  TextSpan parseMarkdown(String text) {
    var startTime = DateTime.now();
    var result = List<TextSpan>.empty(growable: true);
    var index = 0;

    text.split('\n').forEach((line) {
      var head = RegExp('^ *#+ +').hasMatch(line);
      var point = RegExp('^ *- +').hasMatch(line);
      var quote = RegExp('^ *> +').hasMatch(line);
      var list = RegExp('^ *\\d+\\. +').hasMatch(line);

      var base = Theme.of(context).textTheme.bodyText1!;
      if (head) {
        line = line.replaceAll(RegExp('^ *#+ +'), '');
        base = base.copyWith(
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! + 2.0,
          fontWeight: FontWeight.bold,
        );
      }

      if (point) {
        line = line.replaceAll(RegExp('^ *- +'), '• ');
      }

      var bold = RegExp('\\*\\*\\w+\\*\\*').allMatches(line);
      var italic = RegExp('\\*\\w+\\*').allMatches(line);

      var listLine = line.split(' ').map((word) {
        // if (bold) {
        //   base = base.copyWith(fontWeight: FontWeight.bold);
        // }
        //
        // if (italic) {
        //   base = base.copyWith(fontStyle: FontStyle.italic);
        // }

        return TextSpan(
            text: word + ' ',
            style: base.copyWith(
                color: Theme.of(context).textTheme.bodyText1?.color));
      }).toList();
      result.addAll(listLine);
      result.add(TextSpan(
          text: '\n',
          style: base.copyWith(
              color: Theme.of(context).textTheme.bodyText1?.color)));
    });

    var endTime = DateTime.now();
    debugPrint('getTextSpan in (ms):' +
        endTime.difference(startTime).inMilliseconds.toString());
    return TextSpan(children: result);
  }
}
