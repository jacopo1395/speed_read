class Book {
  int? id;
  String? title;
  String? text;
  int? length;
  String? path;
  String? author;
  int? completion;
  DateTime? lastOpen;
  bool? favorite;

  Book(
      {this.id,
      this.title = "unknown title",
      this.text,
      this.length,
      this.path,
      this.author,
      this.completion = 0,
      this.lastOpen,
      this.favorite = false});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['path'] = path ?? "";
    map['title'] = title ?? "unknown title";
    // map['text'] = text ?? "";
    map['length'] = length ?? 0;
    map['author'] = author ?? "unknown author";
    map['completion'] = completion ?? 0;
    // map['lastOpen'] = lastOpen?.toIso8601String();
    // map['favorite'] = favorite ?? false;
    return map;
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      title: map['title'] as String,
      path: map['path'] as String,
      // text: map['text'] as String,
      // length: map['length'] as int,
      author: map['author'] as String,
      completion: map['completion'] as int,
      // lastOpen: DateTime.parse(map['lastOpen'] as String),
      // favorite: map['favorite'] as bool
    );
  }
}
