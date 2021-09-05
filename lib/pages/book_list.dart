import 'dart:ffi';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:pedantic/pedantic.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/dao/book_repository.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:uuid/uuid.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final BookRepository _bookRepository = BookRepository();

  List<Book> books = [];

  _BookListPageState();

  @override
  void initState() {
    super.initState();
    findAllBooks();
  }

  void findAllBooks() async {
    var allBooks = await _bookRepository.findAll();
    setState(() {
      books = allBooks ?? [];
    });
  }

  Future<void> _addBook() async {
    /// Picks a new PDF document from the device
    PDFDoc? _pdfDoc;
    var filePickerResult = await FilePicker.platform.pickFiles();

    /// get info from pdf
    if (filePickerResult != null) {
      _pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
    }

    if (filePickerResult == null || _pdfDoc == null) {
      return;
    }

    // TODO add a message error if file is not valid

    var info = _pdfDoc.info;
    var newBook = Book(
        id: DateTime.now().millisecond,
        uuid: Uuid().v4(),
        path: filePickerResult.files.single.path!,
        title: info.title ?? '',
        author: info.author ?? '');

    unawaited(Future(() async {
      var text = await _pdfDoc!.text;
      newBook.text = text.replaceAll(RegExp('-\n'), '');
      newBook.length = RegExp('\\w*(\$|\\W)').allMatches(text).length;
      newBook.loading = false;
      unawaited(_bookRepository.save(newBook));
      setState(() {});
    }));

    setState(() {
      books.add(newBook);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            buildTopBar(),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: ListView(
              children: books.map((book) => buildBookCard(book)).toList()),
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  SliverAppBar buildTopBar() {
    return SliverAppBar(
      expandedHeight: barHeight,
      floating: false,
      pinned: true,
      backgroundColor: white,
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius))),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(
          'Your Books',
          style: AppThemes.primaryTextTheme.headline1,
        ),
      ),
    );
  }

  Container buildBottomBar() {
    return Container(
      margin: EdgeInsets.only(bottom: padding, left: padding, right: padding),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        color: greenAccent,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: white,
                ),
                onPressed: () {
                  NavigationService().navigateTo(FONT_SETTINGS);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.note_add,
                  color: white,
                ),
                onPressed: () async {
                  await NavigationService().navigateTo(MANUAL_BOOK_PAGE);
                  findAllBooks();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: white,
                ),
                onPressed: _addBook,
              )
            ],
          ),
        ),
      ),
    );
  }

  Card buildBookCard(Book book) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: white,
        child: ListTile(
            leading: book.loading
                ? CircularProgressIndicator()
                : Icon(
                    Icons.book,
                    color: black,
                  ),
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: PopupMenuButton<Option>(
              onSelected: onSelectedOption,
              color: trueWhite,
              icon: Icon(
                Icons.more_vert,
                color: grey,
              ),
              itemBuilder: (BuildContext context) {
                return options.map((Option option) {
                  return PopupMenuItem<Option>(
                      value: option.setBookId(book.id),
                      child: Text(option.title));
                }).toList();
              },
            ),
            onTap: () {
              if (!book.loading) {
                NavigationService().navigateTo(CURSOR_PAGE, arguments: book);
              }
            }));
  }

  void onSelectedOption(Option option) {
    if (option.type == OptionType.REMOVE) {
      setState(() {
        books.removeWhere((elem) => elem.id == option.bookId);
      });
      BookRepository().delete(option.bookId!);
    }
  }
}

class Option {
  final String title;
  final OptionType type;
  int? bookId;

  Option({required this.title, required this.type, this.bookId});

  Option setBookId(int bookId) {
    this.bookId = bookId;
    return this;
  }
}

List<Option> options = <Option>[
  Option(title: 'delete', type: OptionType.REMOVE),
];

enum OptionType { REMOVE }
