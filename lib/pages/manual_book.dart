import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speed_read/dao/book_repository.dart';

import 'package:speed_read/models/book.dart';
import 'package:speed_read/service/local_storage.service.dart';
import 'package:speed_read/service/navigation.service.dart';
import 'package:uuid/uuid.dart';

class ManualBookPage extends StatefulWidget {
  @override
  _ManualBookPageState createState() => _ManualBookPageState();
}

class _ManualBookPageState extends State<ManualBookPage> {
  Book? _book;

  @override
  void initState() {
    _book = Book(id: DateTime.now().millisecond, uuid: Uuid().v4());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add new Book'),
        ),
        body: ListView(
          children: [
            TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: null,
              onChanged: (String value) {
                _book!.text = value;
                _book!.pages = value.split('<div style="page-break-after: always;"></div>');
                _book!.length = value.split(' ').length;
              },
            ),
            TextFormField(
              onChanged: (String value) {
                _book!.title = value;
              },
            ),
            TextFormField(
              onChanged: (String value) {
                _book!.author = value;
              },
            ),
            IconButton(onPressed: () async {
              _book!.loading = false;
              await BookRepository().save(_book!);
              NavigationService().pop();
            }, icon: Icon(Icons.save))
          ],
        ));
  }
}
