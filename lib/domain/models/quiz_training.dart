import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/enums/training_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_training.g.dart';

@JsonSerializable()
class QuizTrainingData extends TrainingData {
  @JsonKey(name: 'image_src')
  final ImageSource imageSrc;
  final String image;
  QuizTrainingData({
    required super.id,
    required super.answer,
    required this.imageSrc,
    required this.image,
    required super.category,
    required super.instructionsVariations,
  });
  factory QuizTrainingData.fromJson(Map<String, dynamic> json) =>
      _$QuizTrainingDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuizTrainingDataToJson(this);
}
