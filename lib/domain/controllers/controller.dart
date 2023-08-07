import 'dart:convert';

import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/enums/training_enum.dart';
import 'package:aphasia/repository/training_session_repository.dart';

abstract class Controller {
  static Future<List<QuizTrainingData>> loadTrainingData(TrainingType t) async {
    return await switch (t) {
      TrainingType.quiz => quizTrainingDataset,
    };
  }

  static Future<List<QuizTrainingData>> get quizTrainingDataset async {
    final jsonString =
        await TrainingDatasetRepository.loadQuizTrainingDataset();
    List<QuizTrainingData> trainingDataset =
        (jsonDecode(jsonString) as List<dynamic>)
            .map((e) => QuizTrainingData.fromJson(e as Map<String, dynamic>))
            .toList();
    return trainingDataset;
  }

  static TrainingSession loadTrainingSession(
    List<TrainingData> trainingDataset,
  ) =>
      TrainingSession(
        trainingDataset: trainingDataset,
      );
}
