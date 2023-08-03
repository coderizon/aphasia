import 'package:aphasia/domain/models/training.dart';

class PatternRecognitionTrainingSession extends TrainingSession {
  PatternRecognitionTrainingSession(
      {required PatternRecognitionTrainingDatasetCategory
          trainingDatasetCategory})
      : super(trainingDatasetCategory: trainingDatasetCategory);

  @override
  bool validateUserAnswer(String answer) {
    bool? missed;
    if (missed = answer != getCurrentDataCorrectAnswer()) {
      userAnswerIncorrect();
    } else {
      userAnswerCorrect();
    }
    return missed;
  }
}

class PatternRecognitionTrainingDatasetOverview
    extends TrainingDatasetOverview {
  PatternRecognitionTrainingDatasetOverview({
    required super.coverSrc,
    required super.cover,
    required super.description,
  });
}

class PatternRecognitionTrainingDatasetCategoryOverview
    extends TrainingDatasetCategoryOverview {
  PatternRecognitionTrainingDatasetCategoryOverview({
    required super.name,
    required super.coverSrc,
    required super.cover,
    required super.description,
    required super.instructionsVariations,
  });
}

class PatternRecognitionTrainingDataset extends TrainingDataset {
  PatternRecognitionTrainingDataset({
    required PatternRecognitionTrainingDatasetOverview overview,
    required List<PatternRecognitionTrainingDatasetCategory> categories,
  }) : super(
          overview: overview,
          categories: categories,
        );
}

class PatternRecognitionTrainingDatasetCategory
    extends TrainingDatasetCategory {
  PatternRecognitionTrainingDatasetCategory({
    required TrainingDatasetCategoryOverview overview,
    required List<PatternRecognitionTrainingData> dataset,
  }) : super(
          overview: overview,
          dataset: dataset,
        );
}

class PatternRecognitionTrainingData extends TrainingData {
  PatternRecognitionTrainingData({
    required super.id,
    required super.answer,
  });
}
