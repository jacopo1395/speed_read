class Book {
  int id;
  String uuid;
  String title;
  String text;
  int length;
  String? path;
  String author;
  int completion;
  bool loading;
  DateTime? lastOpen;
  bool? favorite;

  Book(
      {required this.id,
      required this.uuid,
      this.title = 'unknown title',
      this.text = 'no content',
      this.length = 0,
      this.path,
      this.author = 'unknown author',
      this.completion = 0,
      this.loading = true,
      this.lastOpen,
      this.favorite = false});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['uuid'] = uuid;
    map['path'] = path;
    map['title'] = title;
    map['text'] = text;
    map['length'] = length;
    map['author'] = author;
    map['completion'] = completion;
    map['loading'] = loading ? 1 : 0;
    // map['lastOpen'] = lastOpen?.toIso8601String();
    // map['favorite'] = favorite ?? false;
    return map;
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      uuid: map['uuid'] as String,
      title: map['title'] as String,
      path: (map['path'] != null) ? map['path'] as String : null,
      text: map['text'] as String,
      length: map['length'] as int,
      author: map['author'] as String,
      completion: map['completion'] as int,
      loading: (map['loading'] as int) == 1,
      // lastOpen: DateTime.parse(map['lastOpen'] as String),
      // favorite: map['favorite'] as bool
    );
  }

  Book copyWith({
    int? id,
    String? uuid,
    String? title,
    String? text,
    int? length,
    String? path,
    String? author,
    int? completion,
    DateTime? lastOpen,
    bool? loading,
    bool? favorite,
  }) {
    return Book(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        title: title ?? this.title,
        text: text ?? this.text,
        length: length ?? this.length,
        path: path ?? this.path,
        author: author ?? this.author,
        completion: completion ?? this.completion,
        lastOpen: lastOpen ?? this.lastOpen,
        loading: loading ?? this.loading,
        favorite: favorite ?? this.favorite);
  }
}
