import 'dart:convert';

import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/enums/training_enum.dart';

class QuizTrainingSession extends TrainingSession {
  QuizTrainingSession(
      {required QuizTrainingDatasetCategory super.trainingDatasetCategory});

  @override
  bool validateUserAnswer(String answer) {
    bool? correct;
    if (correct = answer == getCurrentDataCorrectAnswer()) {
      userAnswerCorrect();
    } else {
      userAnswerIncorrect();
    }
    return correct;
  }

  List<String> shuffleTrainingDataset(int lengthOfOutputList) {
    final trainingDataset = trainingDatasetCategory.dataset
        .where((element) => element.id != currentData!.id)
        .toList()
        .sublist(0, lengthOfOutputList);
    trainingDataset.add(currentData!);
    trainingDataset.shuffle();
    return trainingDataset.map((e) => e.answer as String).toList();
  }
}

class QuizTrainingTrainingDatasetOverview extends TrainingDatasetOverview {
  QuizTrainingTrainingDatasetOverview({
    required super.coverSrc,
    required super.cover,
    required super.description,
  });
}

class QuizTrainingDatasetCategoryOverview
    extends TrainingDatasetCategoryOverview {
  QuizTrainingDatasetCategoryOverview({
    required super.name,
    required super.coverSrc,
    required super.cover,
    required super.description,
    required super.instructionsVariations,
  });
}

class QuizTrainingDataset extends TrainingDataset {
  QuizTrainingDataset({
    required QuizTrainingTrainingDatasetOverview overview,
    required List<QuizTrainingDatasetCategory> categories,
  }) : super(
          overview: overview,
          categories: categories,
        );

  factory QuizTrainingDataset.fromJson(String jsonString) {
    Map<String, dynamic> map = TrainingDataset.mapFromJson(jsonString);
    final Map<String, dynamic> categoriesMap = map["categories"];
    final List<QuizTrainingDatasetCategory> categories = categoriesMap.keys
        .map((key) => QuizTrainingDatasetCategory.fromJson(
            jsonEncode(categoriesMap[key]), key))
        .toList();
    final overview = QuizTrainingTrainingDatasetOverview(
      coverSrc: ImageSourceString.encode(map["coverSrc"]!),
      cover: map["cover"]!,
      description: map["description"]!,
    );

    final QuizTrainingDataset trainingDataset = QuizTrainingDataset(
      overview: overview,
      categories: categories,
    );
    return trainingDataset;
  }
}

class QuizTrainingDatasetCategory extends TrainingDatasetCategory {
  QuizTrainingDatasetCategory({
    required TrainingDatasetCategoryOverview overview,
    required List<QuizTrainingData> dataset,
  }) : super(
          overview: overview,
          dataset: dataset,
        );

  factory QuizTrainingDatasetCategory.fromJson(
      String jsonString, String categoryName) {
    Map<String, String> map = TrainingDatasetCategory.mapFromJson(jsonString);
    Map<String, String> instructionsVariations =
        TrainingDatasetCategory.instructionsVariationsMapFromJsonString(
            jsonEncode(map["instructionsVariations"]));
    final List<QuizTrainingData> dataset =
        TrainingDatasetCategory.decodeDatasetFromJson(map["dataset"]!)
            .map((data) => QuizTrainingData.fromJson(jsonEncode(data)))
            .toList();
    final overview = QuizTrainingDatasetCategoryOverview(
        name: categoryName,
        coverSrc: ImageSourceString.encode(map["coverSrc"]!),
        cover: map["cover"]!,
        description: map["description"]!,
        instructionsVariations: instructionsVariations);

    final trainingDatasetCategory = QuizTrainingDatasetCategory(
      overview: overview,
      dataset: dataset,
    );
    return trainingDatasetCategory;
  }
}

class QuizTrainingData extends TrainingData {
  final ImageSource imageSrc;
  final String image;
  final String funFact;
  QuizTrainingData({
    required super.id,
    required super.answer,
    required this.imageSrc,
    required this.image,
    required this.funFact,
  });
  factory QuizTrainingData.fromJson(String jsonString) {
    Map<String, String> map = TrainingData.mapFromJson(jsonString);
    return QuizTrainingData(
      id: map["id"]!,
      answer: map["answer"]!,
      imageSrc: ImageSourceString.encode(map["image_src"]!),
      image: map["image"]!,
      funFact: map["fun_fact"]!,
    );
  }
}
