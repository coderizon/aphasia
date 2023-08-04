import 'package:aphasia/domain/controllers/controller.dart';
import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart';

GetIt serviceLocator = GetIt.I;

void setup() {
  serviceLocator.registerSingletonAsync<QuizTrainingDataset>(
      () async => Controller.quizTrainingDataset);
  serviceLocator.registerFactoryParam<QuizTrainingSession,
          QuizTrainingDatasetCategory, void>(
      (datasetCategory, _) => Controller.loadQuizSession(datasetCategory));
  serviceLocator.registerLazySingleton<SpeechToText>(() => SpeechToText());
}
