import 'package:aphasia/enums/training_enum.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'training.g.dart';

abstract class TrainingData {
  final String category;
  final String id;
  final Object answer;

  @JsonKey(name: 'instructions_variations')
  final Map<String, String> instructionsVariations;

  TrainingData({
    required this.id,
    required this.category,
    required this.instructionsVariations,
    required this.answer,
  });

  Map<String, dynamic> toJson();
}

class TrainingSession extends ChangeNotifier {
  final List<TrainingData> trainingDataset;
  late final Iterator<TrainingData> trainingDatasetIterator;
  final TrainingSessionStatistic _sessionStatistic = TrainingSessionStatistic();
  var _state = TrainingSessionState.neverStarted;
  TrainingData? _currentData;
  TrainingData? get currentData => _currentData;
  String currentInstructionId = 'standard';
  String get currentInstruction =>
      _currentData!.instructionsVariations[currentInstructionId]!;
  TrainingSession({required this.trainingDataset}) {
    trainingDatasetIterator = trainingDataset.iterator;
  }
  TrainingSessionState get state => _state;

  void start() {
    if (_state == TrainingSessionState.listening) {
      throw TrainingSessionException.listening;
    }
    _state = TrainingSessionState.listening;
    nextData();
  }

  void nextData() {
    if (_state != TrainingSessionState.listening) {
      throw TrainingSessionException.notListening;
    }
    _currentData = trainingDatasetIterator.moveNext()
        ? trainingDatasetIterator.current
        : null;
    if (_sessionStatistic.perDatasetStatistics.isNotEmpty) {
      _sessionStatistic.perDatasetStatistics.last.end();
    }
    if (_currentData != null) {
      _sessionStatistic.addTrainingDataStatistic(
          TrainingDataAnswerStatistic(_currentData!.id));
      _sessionStatistic.perDatasetStatistics.last.start();
    }
    notifyListeners();
  }

  ({int successes, int misses}) get answerStats {
    final result = _sessionStatistic.perDatasetStatistics.last;
    return (successes: result.successes, misses: result.misses);
  }

  void stop() {
    if (_state != TrainingSessionState.listening) {
      throw TrainingSessionException.notListening;
    }
    _sessionStatistic.perDatasetStatistics.last.end();
    _state = TrainingSessionState.stopped;
  }

  bool validateUserAnswer(covariant Object answer) {
    bool? correct;
    if (correct = answer == _currentData?.answer) {
      userAnswerCorrect();
    } else {
      userAnswerIncorrect();
    }
    return correct;
  }

  Object getCurrentDataCorrectAnswer() {
    if (_state != TrainingSessionState.listening) {
      throw TrainingSessionException.notListening;
    } else if (_currentData == null) {
      throw throw TrainingSessionException.noCurrentData;
    }
    return _currentData!.answer;
  }

  void userAnswerIncorrect() {
    _sessionStatistic.perDatasetStatistics.last.missed();
  }

  void userAnswerCorrect() {
    _sessionStatistic.perDatasetStatistics.last.succeded();
  }

  String get stats {
    final String f = _sessionStatistic.perDatasetStatistics
        .map((element) =>
            "\n Item: ${element.trainingDataId}, \n   Tries: ${element._misses + element._successes}, \n   Successes: ${element._successes}, \n   Misses: ${element._misses}\n-----\n")
        .toList()
        .toString();
    return f;
  }
}

class TrainingSessionStatistic extends Clock {
  final perDatasetStatistics = <TrainingDataAnswerStatistic>[];

  void addTrainingDataStatistic(TrainingDataAnswerStatistic dataSetStatistic) {
    perDatasetStatistics.add(dataSetStatistic);
  }
}

@JsonSerializable()
class TrainingDataAnswerStatistic extends Clock {
  final String trainingDataId;
  int _misses = 0;
  int _successes = 0;
  TrainingDataAnswerStatistic(this.trainingDataId);
  int get misses => _misses;
  int get successes => _successes;
  void missed() => _misses++;
  void succeded() => _successes++;
  factory TrainingDataAnswerStatistic.fromJson(Map<String, dynamic> json) =>
      _$TrainingDataAnswerStatisticFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingDataAnswerStatisticToJson(this);
}

class Clock {
  late final DateTime _startTime;
  late final DateTime _endTime;

  void start() {
    _startTime = DateTime.now();
  }

  void end() {
    _endTime = DateTime.now();
  }

  Duration get duration => _endTime.difference(_startTime);

  String durationString() {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return "$hours hours and $minutes minutes";
  }
}

class ImageSourceString {
  static ImageSource encode(String coverSrc) {
    if (coverSrc == ImageSource.local.name) {
      return ImageSource.local;
    } else if (coverSrc == ImageSource.www.name) {
      return ImageSource.www;
    } else {
      return ImageSource.www; // Default case
    }
  }
}
