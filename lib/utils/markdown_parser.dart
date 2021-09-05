import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MarkdownParser {
  String text;

  TextSpan? textParsed;

  MarkdownParser(this.text);

  TextSpan getTextSpan(
      BuildContext context, GestureRecognizer? tapRecognizer, double opacity) {
    var result = List<TextSpan>.empty(growable: true);
    text.split('\n').map((line) {
      var head = RegExp('^ *#+ +').hasMatch(line);
      var point = RegExp('^ *- +').hasMatch(line);
      // var quote = RegExp('^ *> +').hasMatch(line);
      // var list = RegExp('^ *\\d+\\. +').hasMatch(line);

      var base = Theme.of(context).textTheme.bodyText1!;
      if (head) {
        line = line.replaceAll(RegExp('^ *#+ +'), '');
        base = base.copyWith(
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! + 2.0,
          fontWeight: FontWeight.bold,
        );
      }

      if (point) {
        line = line.replaceAll(RegExp('^ *- +'), '• ');
      }

      var listLine = line.split(' ').map((word) {
        var bold = RegExp('\\*\\*\\w+\\*\\*').hasMatch(word);
        var italic = RegExp('\\*\\w+\\*').hasMatch(word);

        if(bold){
          base = base.copyWith(fontWeight: FontWeight.bold);
        }

        if(italic){
          base = base.copyWith(fontStyle: FontStyle.italic);
        }

        return TextSpan(
            text: word,
            recognizer: tapRecognizer,
            style: base.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.color
                    ?.withOpacity(opacity)));
      }).toList();
      result.addAll(listLine);
    });
    return TextSpan(children: result);
  }
}
