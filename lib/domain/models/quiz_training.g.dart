// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizTrainingData _$QuizTrainingDataFromJson(Map<String, dynamic> json) =>
    QuizTrainingData(
      id: json['id'] as String,
      answer: json['answer'] as Object,
      imageSrc: $enumDecode(_$ImageSourceEnumMap, json['image_src']),
      image: json['image'] as String,
      category: json['category'] as String,
      instructionsVariations:
          Map<String, String>.from(json['instructions_variations'] as Map),
    );

Map<String, dynamic> _$QuizTrainingDataToJson(QuizTrainingData instance) =>
    <String, dynamic>{
      'category': instance.category,
      'id': instance.id,
      'answer': instance.answer,
      'instructions_variations': instance.instructionsVariations,
      'image_src': _$ImageSourceEnumMap[instance.imageSrc]!,
      'image': instance.image,
    };

const _$ImageSourceEnumMap = {
  ImageSource.www: 'www',
  ImageSource.local: 'local',
};
