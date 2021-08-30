import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
import 'file:///C:/Users/jack1/Documents/flut/speed_read/lib/constants/colors.dart';
import 'file:///C:/Users/jack1/Documents/flut/speed_read/lib/constants/constants.dart';
import 'package:speed_read/dao/book_repository.dart';
import 'package:speed_read/models/book.dart';
import 'package:speed_read/routes.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:speed_read/constants/theme.dart';

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
        title: info.title

        ,
        author: info.author);

    setState(() {
      this.books.add(newBook);
    });
    _bookRepository.save(newBook);
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
          style: AppTheme.primaryTextTheme.headline1,
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
                onPressed: _addBook,
              ),
              IconButton(
                icon: Icon(
                  Icons.note_add,
                  color: purple,
                ),
                onPressed: _addBook,
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
          trailing: Icon(Icons.more_vert),
          onTap: () =>
              NavigationService().navigateTo(CURSOR_PAGE, arguments: book),
        ));
  }
}
