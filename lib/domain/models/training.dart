import 'dart:convert';

import 'package:aphasia/enums/training_enum.dart';
import 'package:flutter/material.dart';

abstract class TrainingDatasetOverview {
  final ImageSource coverSrc;
  final String cover;
  final String description;

  TrainingDatasetOverview({
    required this.coverSrc,
    required this.cover,
    required this.description,
  });
}

abstract class TrainingDatasetCategoryOverview {
  final String name;
  final ImageSource coverSrc;
  final String cover;
  final String description;
  final Map<String, String> instructionsVariations;
  TrainingDatasetCategoryOverview({
    required this.name,
    required this.coverSrc,
    required this.cover,
    required this.description,
    required this.instructionsVariations,
  });
}

abstract class TrainingDataset {
  final TrainingDatasetOverview overview;
  final List<TrainingDatasetCategory> categories;

  TrainingDataset({
    required this.overview,
    required this.categories,
  });

  static Map<String, dynamic> mapFromJson(String jsonString) {
    final map = <String, dynamic>{};
    Map<String, dynamic> trainingDatasetMap = jsonDecode(jsonString);
    map["coverSrc"] = trainingDatasetMap["cover_src"];
    map["cover"] = trainingDatasetMap["cover"];
    map["description"] = trainingDatasetMap["description"];
    map["categories"] = trainingDatasetMap["categories"];
    return map;
  }
}

abstract class TrainingDatasetCategory {
  final TrainingDatasetCategoryOverview overview;
  final List<TrainingData> dataset;

  TrainingDatasetCategory({
    required this.overview,
    required this.dataset,
  });

  static Map<String, String> mapFromJson(String jsonString) {
    final map = <String, String>{};
    final trainingDatasetCategoryMap =
        Map<String, dynamic>.from(jsonDecode(jsonString));
    map["coverSrc"] = trainingDatasetCategoryMap["cover_src"]!;
    map["cover"] = trainingDatasetCategoryMap["cover"]!;
    map["description"] = trainingDatasetCategoryMap["description"]!;
    map["instructionsVariations"] =
        jsonEncode(trainingDatasetCategoryMap["instructions_variations"]);
    map["dataset"] = jsonEncode(trainingDatasetCategoryMap["data"]);
    return map;
  }

  static List<dynamic> decodeDatasetFromJson(String jsonString) {
    final dataset = List<dynamic>.from(jsonDecode(jsonString));
    return dataset;
  }

  static Map<String, dynamic> categoriesMapFromJsonString(String jsonString) =>
      jsonDecode(jsonString);
  static Map<String, String> instructionsVariationsMapFromJsonString(
      String jsonString) {
    final doubleDecodedString = jsonDecode(jsonDecode(jsonString));
    final instructionsVariations =
        Map<String, String>.from(doubleDecodedString);
    return instructionsVariations;
  }
}

abstract class TrainingData {
  final String id;
  final Object answer;
  TrainingData({required this.id, required this.answer});
  static Map<String, String> mapFromJson(String jsonString) {
    final trainingDataMap = Map<String, String>.from(jsonDecode(jsonString));
    return trainingDataMap;
  }
}

abstract class TrainingSession extends ChangeNotifier {
  final TrainingDatasetCategory trainingDatasetCategory;
  final Iterator<TrainingData> _categoryDatasetIterator;
  final _TrainingSessionStatistic _sessionStatistic =
      _TrainingSessionStatistic();
  var _state = TrainingSessionState.neverStarted;
  TrainingData? _currentData;
  TrainingData? get currentData => _currentData;
  final Map<String, String> _instructionsVariations;
  String currentInstructionId = 'standard';
  String get currentInstruction =>
      _instructionsVariations[currentInstructionId]!;
  TrainingSession({required this.trainingDatasetCategory, instructionId})
      : _categoryDatasetIterator = trainingDatasetCategory.dataset.iterator,
        _instructionsVariations =
            trainingDatasetCategory.overview.instructionsVariations {
    print('new created');
  }
  TrainingSessionState get state => _state;

  TrainingData? start() {
    if (_state == TrainingSessionState.listening) {
      throw TrainingSessionException.listening;
    }
    _state = TrainingSessionState.listening;
    return nextData();
  }

  TrainingData? nextData() {
    if (_state != TrainingSessionState.listening) {
      throw TrainingSessionException.notListening;
    }
    _currentData = _categoryDatasetIterator.moveNext()
        ? _categoryDatasetIterator.current
        : null;
    if (_sessionStatistic.perDatasetStatistics.isNotEmpty) {
      _sessionStatistic.perDatasetStatistics.last.end();
    }
    if (_currentData != null) {
      _sessionStatistic.addTrainingDataStatistic(
          _TrainingDataAnswerStatistic(_currentData!.id));
      _sessionStatistic.perDatasetStatistics.last.start();
    }
    // print('salut');
    notifyListeners();
    return _currentData;
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

  bool validateUserAnswer(covariant Object answer);

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

class _TrainingSessionStatistic extends Clock {
  final perDatasetStatistics = <_TrainingDataAnswerStatistic>[];

  void addTrainingDataStatistic(_TrainingDataAnswerStatistic dataSetStatistic) {
    perDatasetStatistics.add(dataSetStatistic);
  }
}

class _TrainingDataAnswerStatistic extends Clock {
  final String trainingDataId;
  int _misses = 0;
  int _successes = 0;
  _TrainingDataAnswerStatistic(this.trainingDataId);
  int get misses => _misses;
  int get successes => _successes;
  void missed() => _misses++;
  void succeded() => _successes++;
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
