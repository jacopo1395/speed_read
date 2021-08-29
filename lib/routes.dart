import 'package:flutter/material.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/pages/book_list.dart';
import 'package:speed_read/pages/cursor_reader.dart';

const BOOK_LIST = '/bookList';
const CURSOR_PAGE = '/cursorReader';

MaterialPageRoute<dynamic> Function(RouteSettings) routes =
    (RouteSettings settings) {
  switch (settings.name) {
    case BOOK_LIST:
      return MaterialPageRoute<BookListPage>(
        builder: (context) {
          return BookListPage();
        },
        settings: settings,
      );

    case CURSOR_PAGE:
      return MaterialPageRoute<CursorReaderPage>(
        builder: (context) {
          return CursorReaderPage(settings.arguments as Book);
        },
        settings: settings,
      );

    default:
      return MaterialPageRoute<BookListPage>(
        builder: (context) {
          return BookListPage();
        },
        settings: settings,
      );
  }
};
