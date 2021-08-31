import 'package:flutter/material.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/pages/book_list.dart';
import 'package:speed_read/pages/cursor_reader.dart';
import 'package:speed_read/pages/font_settings.dart';

const BOOK_LIST = '/bookList';
const CURSOR_PAGE = '/cursorReader';
const FONT_SETTINGS = '/fontSettings';

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

    case FONT_SETTINGS:
      return MaterialPageRoute<FontSettingsPage>(
        builder: (context) {
          return FontSettingsPage();
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
