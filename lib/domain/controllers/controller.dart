import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/repository/training_session_repository.dart';

abstract class Controller {
  static Future<QuizTrainingDataset> get quizTrainingDataset async {
    final jsonString =
        await TrainingDatasetRepository.loadQuizTrainingDataset();
    return QuizTrainingDataset.fromJson(jsonString);
  }

  static QuizTrainingSession loadQuizSession(
          QuizTrainingDatasetCategory trainingDatasetCategory) =>
      QuizTrainingSession(trainingDatasetCategory: trainingDatasetCategory);
}
