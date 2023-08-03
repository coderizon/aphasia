import 'package:flutter/services.dart' show rootBundle;

class TrainingDatasetRepository {
  static Future<String> loadQuizTrainingDataset() async {
    return await rootBundle.loadString('assets/quiz_training_dataset.json');
  }

  static Future<String> loadPatternRecognitionTrainingDataset() async {
    return await rootBundle
        .loadString('assets/pattern_recognition_training_dataset.json');
  }

  static Future<String> loadClozeTextTrainingDataset() async {
    return await rootBundle
        .loadString('assets/cloze_text_training_dataset.json');
  }

  static Future<String> loadPuzzleTrainingDataset() async {
    return await rootBundle.loadString('assets/puzzle_training_dataset.json');
  }

  static Future<String> loadMatchingTrainingDataset() async {
    return await rootBundle.loadString('assets/matching_training_dataset.json');
  }

  static Future<String> loadTrainingStatistics() async {
    return await rootBundle.loadString('assets/training_statistics.json');
  }
}
