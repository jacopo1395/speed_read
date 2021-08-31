import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:speed_read/constants/colors.dart';
import 'package:speed_read/constants/constants.dart';
import 'package:speed_read/constants/theme.dart';
import 'package:speed_read/dao/book_repository.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  BookRepository _bookRepository = BookRepository();

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

    PDFDocInfo info = _pdfDoc.info;
    var newBook = Book(
        path: filePickerResult.files.single.path,
        title: info.title,
        author: info.author);
    int id = await _bookRepository.save(newBook);
    newBook.id = id;
    setState(() {
      this.books.add(newBook);
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
      backgroundColor: greenPrimary,
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius))),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(
          "Your Books",
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
          padding: const EdgeInsets.all(padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: purple,
                ),
                onPressed: () {
                  NavigationService().navigateTo(FONT_SETTINGS);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.note_add,
                  color: purple,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: purple,
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
        color: greenSecondary,
        child: ListTile(
          // leading: Icon(Icons.favorite_border),
          title: Text(book.title ?? "unknown title"),
          subtitle: Text(book.author ?? "unknown author"),
          trailing: PopupMenuButton<Option>(
            onSelected: onSelectedOption,
            color: white,
            icon: Icon(
              Icons.more_vert,
              color: grey,
            ),
            itemBuilder: (BuildContext context) {
              return options.map((Option option) {
                return PopupMenuItem<Option>(
                    value: option.setBookId(book.id!),
                    child: Text(option.title));
              }).toList();
            },
          ),
          onTap: () =>
              NavigationService().navigateTo(CURSOR_PAGE, arguments: book),
        ));
  }

  void onSelectedOption(Option option) {
    if (option.type == OptionType.REMOVE) {
      setState(() {
        this.books.removeWhere((elem) => elem.id == option.bookId);
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
  Option(title: "delete", type: OptionType.REMOVE),
];


enum OptionType { REMOVE }
