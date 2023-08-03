import 'package:aphasia/domain/models/training.dart';

class ClozeTextTrainingSession extends TrainingSession {
  ClozeTextTrainingSession(
      {required ClozeTextTrainingDatasetCategory trainingDatasetCategory})
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

class ClozeTextRecognitionTrainingDatasetOverview
    extends TrainingDatasetOverview {
  ClozeTextRecognitionTrainingDatasetOverview({
    required super.coverSrc,
    required super.cover,
    required super.description,
  });
}

class ClozeTextTrainingDatasetCategoryOverview
    extends TrainingDatasetCategoryOverview {
  ClozeTextTrainingDatasetCategoryOverview({
    required super.name,
    required super.coverSrc,
    required super.cover,
    required super.description,
    required super.instructionsVariations,
  });
}

class ClozeTextTrainingDataset extends TrainingDataset {
  ClozeTextTrainingDataset({
    required ClozeTextRecognitionTrainingDatasetOverview overview,
    required List<ClozeTextTrainingDatasetCategory> categories,
  }) : super(
          overview: overview,
          categories: categories,
        );
}

class ClozeTextTrainingDatasetCategory extends TrainingDatasetCategory {
  ClozeTextTrainingDatasetCategory({
    required TrainingDatasetCategoryOverview overview,
    required List<ClozeTextTrainingData> dataset,
  }) : super(
          overview: overview,
          dataset: dataset,
        );
}

class ClozeTextTrainingData extends TrainingData {
  ClozeTextTrainingData({
    required super.id,
    required super.answer,
  });
}
