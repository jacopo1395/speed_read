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
import 'package:speed_read/utils/splitted_text.dart';
import 'package:speed_read/utils/utils.dart';

class CursorReaderPage extends StatefulWidget {
  final Book book;

  CursorReaderPage(this.book);

  @override
  _CursorReaderPageState createState() => _CursorReaderPageState(book);
}

class _CursorReaderPageState extends State<CursorReaderPage> {
  Book book;

  int _cursor = 0;

  List<String> _paragraphsText = [];
  List<int> _paragraphsLength = [];

  int _paragraphIndex = 1;
  int _totalPages = 0;

  Timer? _timer;
  int _speed = SharedPreferenceService().speed;

  final PageController _pageController = PageController();
  final DynamicSize _dynamicSize = DynamicSizeImpl();
  final SplittedText _splittedText = SplittedTextImpl();
  final GlobalKey pageKey = GlobalKey();
  Size? _size;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initReader();
    });
    super.initState();
  }

  Future<void> initReader() async {
    _size = _dynamicSize.getSize(pageKey);

    _paragraphsText = _splittedText.getSplittedText(
        _size!, Theme
        .of(context)
        .textTheme
        .bodyText1!
        .copyWith(), book.text!);

    _paragraphsLength =
        _paragraphsText.map((e) =>
        e
            .split(RegExp('\\w*\\W'))
            .length).toList();

    book = await refreshBook();
    setState(() {
      _totalPages = _paragraphsText.length;
      _paragraphIndex = findParagraph();
      _cursor = book.completion;
    });
   _pageController.animateToPage(
        _paragraphIndex - 1, duration: Duration(milliseconds: 50),
        curve: Curves.easeInToLinear);
  }

  _CursorReaderPageState(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
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
        bottomNavigationBar: buildBottomBar());
  }

  Expanded buildReader() {
    return Expanded(
      child: Container(
        key: pageKey,
        child: PageView.builder(
            controller: _pageController,
            onPageChanged: (val) {
              setState(() {
                _paragraphIndex = val + 1;
              });
            },
            itemCount: _totalPages,
            itemBuilder: (context, index) {
              return buildRichText(index);
            }),
      ),
    );
  }

  RichText buildRichText(int paragraph) {
    return RichText(
      text: TextSpan(
          children: RegExp('\\w*\\W')
              .allMatches(_paragraphsText[paragraph])
              .mapIndexed((word, index) =>
              TextSpan(
                  text: word.group(0),
                  recognizer: _tapRecognizer(getNumberWord(paragraph, index)),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(
                      color: Theme
                          .of(context)
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
        Text(((1/_speed*1000)*60).round().toString()+' words/min.'),
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
    _timer ??= Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_cursor >= book.length!) {
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
              padding: const EdgeInsets.all(padding),
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
        debugPrint(i.toString());
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
    return (await BookRepository().findById(book.id!))!;
  }
}
