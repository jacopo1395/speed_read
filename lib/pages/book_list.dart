import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_text/pdf_text.dart';
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
    if (filePickerResult != null) {
      _pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
    }

    if (filePickerResult == null || _pdfDoc == null) {
      return;
    }

    String text =
        "Ciao questo è un testo di prova, deve essere molto lungo taajkslf asdf asd asd fa f asf sf asd fa fs df asd fs fs df hkljlksdjf sdf ";
    // String text = await _pdfDoc.text;
    PDFDocInfo info = _pdfDoc.info;
    var newBook = Book(
        path: filePickerResult.files.single.path,
        title: info.title,
        text: text,
        length: text.length,
        author: info.author);

    setState(() {
      this.books.add(newBook);
    });
    _bookRepository.save(newBook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Books"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
          children: books
              .map((book) => ListTile(
                    title: Text(book.title ?? "unknown title"),
                    onTap: () => NavigationService()
                        .navigateTo(CURSOR_PAGE, arguments: book),
                  ))
              .toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add Book',
        child: Icon(Icons.add),
      ), // This tr
    );
  }
}
