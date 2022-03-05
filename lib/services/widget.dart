//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';

/// static class(widget)
class WG {

  static const pagePad = EdgeInsets.all(20);

  ///get appBar widget
  ///@title title string
  static AppBar appBar(String title) {
    return AppBar(
      toolbarHeight: 42,
      title: WidgetUt.text(15, title, Colors.white),
    );
  }

  ///display label & text
  static Column labelText(String label, String text, [Color? color]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WidgetUt.text(14, label, Colors.grey),
        WidgetUt.text(18, text, color),
        WidgetUt.divider(),
      ]
    );
  }

  ///input field style
  static TextStyle inputStyle([bool status = true]) {    
    return TextStyle(
      fontSize: 18,
      color: status ? Colors.black : Colors.grey,
    );
  }

  //return label
  static InputDecoration inputLabel(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        height: 0.8,
      ),
    );
  }

  ///create TextButton
  ///VoidCallback is need, onPressed on ()=> before function !!
  static TextButton textBtn(String text, [VoidCallback? fnOnClick, Color? color]) {
    var status = (fnOnClick != null);
    var color2 = (!status) ? Colors.grey :
      (color == null) ? Colors.blue :
      color;
    return TextButton(
      child: WidgetUt.text(15, text, color2),
      onPressed: status ? fnOnClick : null,
    ); 
  }

  ///one button at form end/tail
  static Container tailBtn(String text, [VoidCallback? fnOnClick, double? top]) {
    var status = (fnOnClick != null);
    return Container(
        alignment: Alignment.center,
        margin: (top == null) 
          ? WidgetUt.gap(15) : EdgeInsets.only(top:top, right:15, bottom:15, left:15),
        child: ElevatedButton(          
          child: WidgetUt.text(16, text),
          onPressed: status ? fnOnClick : null,
        ));
  }

} //class
