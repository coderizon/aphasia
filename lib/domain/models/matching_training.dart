import 'package:aphasia/domain/models/training.dart';

class MatchingTrainingSession extends TrainingSession {
  MatchingTrainingSession(
      {required MatchingRecognitionTrainingDatasetCategory
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

class MatchingRecognitionTrainingDatasetOverview
    extends TrainingDatasetOverview {
  MatchingRecognitionTrainingDatasetOverview({
    required super.coverSrc,
    required super.cover,
    required super.description,
  });
}

class MatchingRecognitionTrainingDatasetCategoryOverview
    extends TrainingDatasetCategoryOverview {
  MatchingRecognitionTrainingDatasetCategoryOverview({
    required super.name,
    required super.coverSrc,
    required super.cover,
    required super.description,
    required super.instructionsVariations,
  });
}

class MatchingRecognitionTrainingDataset extends TrainingDataset {
  MatchingRecognitionTrainingDataset({
    required MatchingRecognitionTrainingDatasetOverview overview,
    required List<MatchingRecognitionTrainingDatasetCategory> categories,
  }) : super(
          overview: overview,
          categories: categories,
        );
}

class MatchingRecognitionTrainingDatasetCategory
    extends TrainingDatasetCategory {
  MatchingRecognitionTrainingDatasetCategory({
    required TrainingDatasetCategoryOverview overview,
    required List<MatchingRecognitionTrainingData> dataset,
  }) : super(
          overview: overview,
          dataset: dataset,
        );
}

class MatchingRecognitionTrainingData extends TrainingData {
  MatchingRecognitionTrainingData({
    required super.id,
    required super.answer,
  });
}
