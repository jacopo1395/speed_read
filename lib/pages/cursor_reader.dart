import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/dao/book_repository.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:speed_read/service/shared_preferences.service.dart';
import 'package:speed_read/utils/dynamic_size.dart';
import 'package:speed_read/utils/markdown_parser.dart';
import 'package:speed_read/utils/splitted_text.dart';
import 'package:speed_read/utils/utils.dart';
import 'package:speed_read/widgets/Paginator.dart';

class CursorReaderPage extends StatefulWidget {
  final Book book;

  CursorReaderPage(this.book);

  @override
  _CursorReaderPageState createState() => _CursorReaderPageState(book);
}

class _CursorReaderPageState extends State<CursorReaderPage> {
  Book book;

  int _cursor = 0;

  List<TextSpan> _paragraphsText = [];
  List<int> _paragraphsLength = [];

  int _paragraphIndex = 1;
  int _totalPages = 0;

  Timer? _timer;
  int _speed = SharedPreferenceService().speed;

  final PageController _pageController = PageController();
  final DynamicSize _dynamicSize = DynamicSize();
  final SplittedText _splittedText = SplittedText();
  final GlobalKey pageKey = GlobalKey();
  Size? _size;

  late TextSpan textParsed;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initReader();
    });
    super.initState();
  }

  Future<void> initReader() async {
    // book = await refreshBook();

    // textParsed = getTextSpan();

    _size = _dynamicSize.getSize(pageKey, context);
    _totalPages = book.pages.length;

    // _paragraphsText = _splittedText.getSplittedText(_size!, textParsed);
    // _paragraphsLength = _paragraphsText.map((e) => e.children!.length).toList();

    setState(() {
      // _totalPages = _paragraphsText.length;
      // _paragraphIndex = findParagraph();
      // _cursor = book.completion;
    });
    // unawaited(_pageController.animateToPage(_paragraphIndex - 1,
    //     duration: Duration(milliseconds: 50), curve: Curves.easeInToLinear));
  }

  _CursorReaderPageState(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildBody(), bottomNavigationBar: buildBottomBar());
  }

  Container buildBody() {
    return Container(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              buildToolBar(),
              buildReader(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildReader() {
    return Expanded(
      child: Container(
          key: pageKey,
          child: FutureBuilder<Book>(
            future: refreshBook(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Container(color: Colors.red,)
                  // : Container(color: Colors.red,);
                  : Paginator(snapshot.data!, _size!);
            },
          )),
    );
  }

  RichText buildRichText(int paragraph) {
    return RichText(
      text: TextSpan(
          children: RegExp('\\w*(\$|\\W)')
              .allMatches(_paragraphsText[paragraph].text!)
              .mapIndexed((word, index) => TextSpan(
                  text: word.group(0),
                  recognizer: _tapRecognizer(getNumberWord(paragraph, index)),
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.color
                          ?.withOpacity(
                              opacity(getNumberWord(paragraph, index))))))
              .toList()),
    );
  }

  int getNumberWord(int paragraph, int index) {
    var offset = 0;
    for (var i = 0; i < paragraph; i++) {
      offset += _paragraphsLength[i];
    }
    return index + offset;
  }

  Row buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: Icon(
              Icons.settings,
              color: black,
            ),
            onPressed: () async {
              stopTimer();
              await NavigationService().navigateTo(FONT_SETTINGS);
              initReader();
            }),
        Text(((1 / _speed * 1000) * 60).round().toString() + ' words/min.'),
        Material(
          color: black,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$_paragraphIndex/$_totalPages',
              style: TextStyle(color: white),
            ),
          ),
        ),
      ],
    );
  }

  double opacity(int index) {
    var distance = (index.toDouble() - _cursor).abs();
    return max(1.0 - (distance * 0.2), 0.2);
  }

  void startTimer() {
    var oneSec = Duration(milliseconds: _speed);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_cursor + 2 >=
            _paragraphsLength.reduce((value, element) => value + element)) {
          // end of book
          _timer!.cancel();
        }

        if (_cursor + 1 ==
            _paragraphsLength
                .getRange(0, _paragraphIndex)
                .reduce((value, element) => value + element)) {
          setState(() {
            //next page
            _paragraphIndex++;
            _pageController.animateToPage(_paragraphIndex - 1,
                duration: Duration(milliseconds: 50),
                curve: Curves.easeInToLinear);
          });
        } else {
          // next word
          debugPrint(_cursor.toString());
          setState(() {
            _cursor++;
            BookRepository().update(book.copyWith(completion: _cursor));
          });
        }
      },
    );
  }

  void stopTimer() {
    setState(() {
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    });
  }

  void resetTimer() {
    setState(() {
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }

  Container buildBottomBar() {
    return Container(
      margin: EdgeInsets.only(bottom: padding, left: padding, right: padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider(
          //   value: _pageIndex.floorToDouble(),
          //   min: 1,
          //   max: _pages.toDouble(),
          //   onChanged: (double value) {
          //     setState(() {
          //       _pageIndex = value.toInt();
          //     });
          //     loadPdf();
          //   },
          // ),
          Material(
            color: greenAccent,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // IconButton(
                  //   icon: Icon(Icons.skip_previous),
                  //   onPressed: () {},
                  //   color: purple,
                  // ),
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    onPressed: decreaseSpeed,
                    color: purple,
                  ),
                  buildPlayPause(),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    onPressed: increaseSpeed,
                    color: purple,
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.skip_next),
                  //   onPressed: () {},
                  //   color: purple,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconButton buildPlayPause() {
    return _timer != null && _timer!.isActive
        ? IconButton(
            icon: Icon(Icons.pause),
            onPressed: stopTimer,
            color: purple,
          )
        : IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: startTimer,
            color: purple,
          );
  }

  void increaseSpeed() {
    debugPrint(_speed.toString());
    setState(() {
      _speed -= 10;
    });
    SharedPreferenceService().setSpeed(_speed);
    resetTimer();
    startTimer();
  }

  void decreaseSpeed() {
    debugPrint(_speed.toString());
    setState(() {
      _speed += 10;
    });
    SharedPreferenceService().setSpeed(_speed);
    resetTimer();
    startTimer();
  }

  GestureRecognizer? _tapRecognizer(int index) {
    return TapGestureRecognizer()
      ..onTap = () async {
        setState(() {
          _cursor = index;
        });
        var i =
            await BookRepository().update(book.copyWith(completion: _cursor));
        debugPrint(_cursor.toString());
      };
  }

  int findParagraph() {
    var result = 1;
    var sum = 0;
    for (var i = 0; i < _paragraphsLength.length; i++) {
      sum += _paragraphsLength[i];
      if (book.completion < sum) {
        result = i + 1;
        break;
      }
    }
    return result;
  }

  Future<Book> refreshBook() async {
    var start = DateTime.now();
    var result = (await BookRepository().findById(book.id))!;
    var end = DateTime.now();
    debugPrint('retrieve book in (ms): ' +
        end.difference(start).inMilliseconds.toString());
    return result;
  }

  TextSpan getTextSpan(Book book, {int? paragraphIndex = -1}) {
    var startTime = DateTime.now();
    var result = List<TextSpan>.empty(growable: true);
    var index = 0;

    book.text.split('\n').forEach((line) {
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
            recognizer: _tapRecognizer(index),
            style: base.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.color
                    ?.withOpacity(opacity(index++))));
      }).toList();
      result.addAll(listLine);
      result.add(TextSpan(
          text: '\n',
          recognizer: _tapRecognizer(index),
          style: base.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.color
                  ?.withOpacity(opacity(index++)))));
    });

    if (paragraphIndex! >= 0) {
      var start = 0;
      for (var i = 0; i < paragraphIndex; i++) {
        start += _paragraphsLength[i];
      }
      result = result.sublist(start, start + _paragraphsLength[paragraphIndex]);
    }
    var endTime = DateTime.now();
    debugPrint('getTextSpan in (ms):' +
        endTime.difference(startTime).inMilliseconds.toString());
    return TextSpan(children: result);
  }
}
