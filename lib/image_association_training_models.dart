import 'package:aphasia/image_association_session_widgets.dart';
import 'package:aphasia/training_session_models.dart';
import 'package:flutter/material.dart';

class ImageWordAssociationSession extends TrainingSession {
  ImageWordAssociationSession() : super(title: 'quiz');

  @override
  void initializeTrainingDataSet() {
    trainingSessionDataSet
      ..add((
        imageSrc: 'i',
        imageUnit: ImageUnit.letter,
        name: 'i',
        category: DataCategory.letters.value
      ))
      ..add((
        imageSrc: 'a',
        imageUnit: ImageUnit.letter,
        name: 'a',
        category: DataCategory.letters.value
      ))
      ..add((
        imageSrc: 'b',
        imageUnit: ImageUnit.letter,
        name: 'b',
        category: DataCategory.letters.value
      ))
      ..add((
        imageSrc: 'y',
        imageUnit: ImageUnit.letter,
        name: 'y',
        category: DataCategory.letters.value
      ))
      ..add((
        imageSrc: 'ü',
        imageUnit: ImageUnit.letter,
        name: 'ü',
        category: DataCategory.letters.value
      ))
      ..add((
        imageSrc:
            'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=880&q=80',
        imageUnit: ImageUnit.pixel,
        name: 'bannana',
        category: DataCategory.fruits.value
      ))
      ..add((
        imageSrc:
            'https://images.unsplash.com/photo-1546556928-174b0dbfee44?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        imageUnit: ImageUnit.pixel,
        name: 'ananas',
        category: DataCategory.fruits.value
      ))
      ..add((
        imageSrc:
            'https://images.unsplash.com/photo-1564874997803-e4d589d5fd41?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        imageUnit: ImageUnit.pixel,
        name: 'tomato',
        category: DataCategory.fruits.value
      ))
      ..add((
        imageSrc:
            'https://images.unsplash.com/photo-1592840496694-26d035b52b48?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=825&q=80',
        imageUnit: ImageUnit.pixel,
        name: 'haxe',
        category: DataCategory.tools.value
      ));
  }

  @override
  void initializeUserInputListeners() {
    userInputListerners['default'] = _Multichoice();
  }

  @override
  Widget startSession({
    required BuildContext context,
    required String targetDataCategory,
  }) {
    super.startSession(
      context: context,
      targetDataCategory: targetDataCategory,
    );
    return getImageWordAssociationSessionWidget(context: context);
  }
}

class _Multichoice extends UserInputListener {
  @override
  bool validateInput(
      {required String correctAnswer, required String userInput}) {
    return correctAnswer == userInput;
  }
}
