import 'package:flutter/material.dart';

Widget generateLetterContainer(
  String letter, {
  double width = 50,
  double height = 50,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.yellow, // Replace with your desired background color
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
