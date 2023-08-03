import 'package:aphasia/domain/models/training.dart';

class PuzzleTrainingSession extends TrainingSession {
  PuzzleTrainingSession(
      {required PuzzleTrainingDatasetCategory trainingDatasetCategory})
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

class PuzzleTrainingDatasetOverview extends TrainingDatasetOverview {
  PuzzleTrainingDatasetOverview({
    required super.coverSrc,
    required super.cover,
    required super.description,
  });
}

class PuzzleTrainingDatasetCategoryOverview
    extends TrainingDatasetCategoryOverview {
  PuzzleTrainingDatasetCategoryOverview({
    required super.name,
    required super.coverSrc,
    required super.cover,
    required super.description,
    required super.instructionsVariations,
  });
}

class PuzzleTrainingDataset extends TrainingDataset {
  PuzzleTrainingDataset({
    required PuzzleTrainingDatasetOverview overview,
    required List<PuzzleTrainingDatasetCategory> categories,
  }) : super(
          overview: overview,
          categories: categories,
        );
}

class PuzzleTrainingDatasetCategory extends TrainingDatasetCategory {
  PuzzleTrainingDatasetCategory({
    required TrainingDatasetCategoryOverview overview,
    required List<PuzzleTrainingData> dataset,
  }) : super(
          overview: overview,
          dataset: dataset,
        );
}

class PuzzleTrainingData extends TrainingData {
  PuzzleTrainingData({
    required super.id,
    required super.answer,
  });
}
