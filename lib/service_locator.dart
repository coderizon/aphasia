import 'package:aphasia/domain/controllers/controller.dart';
import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/domain/models/training.dart';
import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart';

GetIt serviceLocator = GetIt.I;

void setup() {
  serviceLocator.registerSingletonAsync<List<QuizTrainingData>>(
    () async => Controller.quizTrainingDataset,
  );
  serviceLocator
      .registerFactoryParam<TrainingSession, List<QuizTrainingData>, void>(
    (dataset, _) => Controller.loadTrainingSession(dataset),
  );

  serviceLocator.registerLazySingleton<SpeechToText>(() => SpeechToText());
}
