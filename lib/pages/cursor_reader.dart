import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/utils.dart';

class CursorReaderPage extends StatefulWidget {
  final Book book;

  CursorReaderPage(this.book);

  @override
  _CursorReaderPageState createState() => _CursorReaderPageState(book);
}

class _CursorReaderPageState extends State<CursorReaderPage> {
  int _selectedIndex = 0;
  int _counter = 0;
  int _length = 0;
  String textToRead = "";
  Timer? _timer;
  Book book;
  int _pageIndex = 1;

  PDFDoc? _pdfDoc;

  @override
  void initState() {
    loadPdf();
  }

  void loadPdf() async {
    /// Picks a new PDF document from the device

    _pdfDoc = await PDFDoc.fromPath(book.path!);

    if (_pdfDoc == null) {
      return;
    }

    // String text =
    //     "Ciao questo è un testo di prova, deve essere molto lungo taajkslf asdf asd asd fa f asf sf asd fa fs df asd fs fs df hkljlksdjf sdf ";

    String text = await _pdfDoc!.pageAt(_pageIndex).text;
    setState(() {
      this.textToRead = text;
      _length = textToRead.split(" ").length;
    });
  }

  _CursorReaderPageState(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                  children: textToRead
                      .split(" ")
                      .mapIndexed((word, index) => TextSpan(
                          text: word + " ",
                          style: TextStyle(
                              color: Colors.black.withOpacity(opacity(index)))))
                      .toList()),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: "play"),
          BottomNavigationBarItem(icon: Icon(Icons.pause), label: "pause"),
          BottomNavigationBarItem(icon: Icon(Icons.undo), label: "reset")
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  double opacity(int index) {
    var distance = (index.toDouble() - _counter).abs();
    return max(1.0 - (distance * 0.2), 0.2);
  }

  void startTimer() {
    const oneSec = const Duration(milliseconds: 500);
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
      _counter = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        startTimer();
      }
      if (_selectedIndex == 1) {
        stopTimer();
      }
      if (_selectedIndex == 2) {
        resetTimer();
      }
    });
  }
}
