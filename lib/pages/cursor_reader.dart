import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:speed_read/service/shared_preferences.service.dart';
import 'package:speed_read/utils.dart';

class CursorReaderPage extends StatefulWidget {
  final Book book;

  CursorReaderPage(this.book);

  @override
  _CursorReaderPageState createState() => _CursorReaderPageState(book);
}

class _CursorReaderPageState extends State<CursorReaderPage> {
  int _counter = 0;
  int _length = 0;
  String textToRead = "";
  Timer? _timer;
  Book book;
  int _pageIndex = 1;
  int _pages = 1;
  int _speed = SharedPreferenceService().speed;

  PDFDoc? _pdfDoc;

  @override
  void initState() {
    loadPdf();
  }

  void loadPdf() async {
    _pdfDoc = await PDFDoc.fromPath(book.path!);
    if (_pdfDoc == null) {
      return;
    }

    String text = await _pdfDoc!.pageAt(_pageIndex).text;
    _pages = await _pdfDoc!.pages.length;
    setState(() {
      this.textToRead = text;
      _length = textToRead.split(" ").length;
    });
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
      child: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
              children: textToRead
                  .split(" ")
                  .mapIndexed((word, index) => TextSpan(
                      text: word + " ",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color
                              ?.withOpacity(opacity(index)))))
                  .toList()),
        ),
      ),
    );
  }

  Row buildToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: Icon(
              Icons.settings,
              color: purple,
            ),
            onPressed: () {
              NavigationService().navigateTo(FONT_SETTINGS);
            }),
        Material(
          color: purple,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "$_pageIndex/$_pages",
              style: TextStyle(color: white),
            ),
          ),
        ),
      ],
    );
  }

  double opacity(int index) {
    var distance = (index.toDouble() - _counter).abs();
    return max(1.0 - (distance * 0.2), 0.2);
  }

  void startTimer() {
    var oneSec = Duration(milliseconds: _speed);
    if (_timer == null) {
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) {
          if (_counter >= _length) {
            setState(() {
              _pageIndex++;
              if (_pageIndex <= _pdfDoc!.pages.length) {
                _counter = 0;
                loadPdf();
              } else {
                timer.cancel();
              }
            });
          } else {
            debugPrint(DateTime.now().toIso8601String());
            setState(() {
              _counter++;
            });
          }
        },
      );
    }
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
}
