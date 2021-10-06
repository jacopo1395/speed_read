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

enum OptionType { REMOVE }

List<Option> options = <Option>[
  Option(title: 'delete', type: OptionType.REMOVE),
];