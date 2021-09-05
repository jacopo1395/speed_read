// import 'dart:ui';
//
// import 'package:pdf_text/pdf_text.dart';
// import 'package:speed_read/utils/splitted_text.dart';
// import 'package:flutter/material.dart';
//
// class PageManager {
//   PDFDoc pdfDoc;
//   List<Page> pages = List.empty();
//   int pageNumber = 1;
//   final SplittedText _splittedText = SplittedText();
//
//   List<String> _paragraphsText = [];
//   List<int> _paragraphsLength = [];
//   Size size;
//   TextStyle textStyle;
//
//   PageManager(this.pdfDoc, this.size, this.textStyle) {
//     loadPdfPage(0);
//   }
//
//   void loadPdfPage(int pageIndex) async {
//     var text = await pdfDoc.text;
//     _paragraphsText = _splittedText.getSplittedText(size, textStyle, text);
//     _paragraphsLength =
//         _paragraphsText.map((e) => e.allMatches(' ').length + 1).toList();
//     pageNumber = pageIndex;
//   }
//
//   int getPage() {
//     return pageNumber;
//   }
//
//   Future<void> cacheThreePage() async {
//     await cacheNextPage(pageNumber);
//     await cacheNextPage(pageNumber + 1);
//   }
//
//   Future<void> cacheNextPage(int index) async {
//     if (index <= pdfDoc.pages.length) {
//       var pdfPage = pdfDoc.pageAt(index);
//       var pdfText = await pdfPage.text;
//       pages.insert(index, Page(pdfText));
//     }
//   }
//
//   // String getPage(int index) {
//   //   if (index == pageNumber) {
//   //     return pages[0].text;
//   //   }
//   //   if (index == pageNumber - 1) {
//   //     cacheNextPage(index - 1);
//   //     return pages[1].text;
//   //   }
//   //   if (index == pageNumber + 1) {
//   //     return pages[2].text;
//   //   }
//   //
//   //   pageNumber = index;
//   //   return pages[2].text;
//   // }
//
// // pageNumber
// }
//
// class Page {
//   String text;
//
//   Page(this.text);
// }
