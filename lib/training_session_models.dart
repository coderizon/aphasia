import 'package:flutter/material.dart';

enum ImageUnit {
  letter,
  pixel;
}

enum DataCategory {
  fruits('fruits', 'This is a fruit', 'Which fruit is it?'),
  tools('tools', 'This is a tool', 'Which tool is it?'),
  letters('letters', 'This is a letter', 'Which letter is it?');

  const DataCategory(this.value, this.introduction, this.question);
  final String value;
  final String introduction;
  final String question;
}

typedef TrainingSessionData = ({
  String imageSrc,
  ImageUnit imageUnit,
  String name,
  String category
});

enum RecognitionDifficulty {
  hard,
  easy,
  medium;
}

class SessionResult {
  final DateTime sessionDate;
  final int targetDataIndex;
  final String targetDataCategory;
  int misses = 0;
  int successes = 0;
  RecognitionDifficulty? recognitionDifficulty;
  SessionResult({
    required this.sessionDate,
    required this.targetDataCategory,
    required this.targetDataIndex,
    required bool succeded,
  }) {
    this.succeded = succeded;
  }
  set succeded(bool succeded) {
    if (succeded) {
      successes++;
    } else {
      misses++;
    }
  }
}

class UserInputListener {
  bool validateInput({
    required String correctAnswer,
    required String userInput,
  }) {
    return correctAnswer.compareTo(userInput) == 0;
  }
}

abstract class TrainingSession with ChangeNotifier {
  final String title;
  bool _started = false;
  DateTime? _lastTimeStarted;
  int _lastTargetDataIndex = 0;
  late String _targetDataCategory;
  get targetDataCategory => _targetDataCategory;
  DateTime? _duration;
  final _sessionResults = <SessionResult>[];
  final trainingSessionDataSet = <TrainingSessionData>[];
  final userInputListerners = <String, UserInputListener>{};
  String inputListener = 'default';
  get started => _started;
  get lastTargetDataIndex => _lastTargetDataIndex;
  bool _inputIsFirstAttemptForCurrentCategory = true;
  get inputIsFirstAttemptForCurrentCategory =>
      _inputIsFirstAttemptForCurrentCategory;
  void resetLastTargetDataIndex() {
    _lastTargetDataIndex = 0;
  }

  get duration => _duration;
  int get lastSessionResult => _sessionResults.length - 1;

  TrainingSession({required this.title}) {
    initializeTrainingDataSet();
    initializeUserInputListeners();
  }
  void initializeTrainingDataSet();
  void initializeUserInputListeners();
  Widget startSession(
      {required BuildContext context, required String targetDataCategory}) {
    _startTrainingSession(
      targetDataCategory: targetDataCategory,
    );
    return const Placeholder();
  }

  void _startTrainingSession({
    required String targetDataCategory,
  }) {
    _targetDataCategory = targetDataCategory;
    _lastTimeStarted = DateTime.now();
    _started = true;
    // notifyListeners();
  }

  void listenUserInput({
    required String userInput,
  }) {
    bool succeded = userInputListerners[inputListener]?.validateInput(
          correctAnswer:
              getDataSet(index: lastTargetDataIndex).name.toLowerCase(),
          userInput: userInput.toLowerCase(),
        ) ??
        false;
    print('User input $userInput');
    print('Correct Input ${getDataSet(index: lastTargetDataIndex).name}');
    if (_inputIsFirstAttemptForCurrentCategory) {
      final result = SessionResult(
        targetDataCategory: _targetDataCategory,
        sessionDate: _lastTimeStarted!,
        targetDataIndex: _lastTargetDataIndex,
        succeded: succeded,
      );
      _inputIsFirstAttemptForCurrentCategory = false;
      _sessionResults.add(result);
    } else {
      _sessionResults.last.succeded = succeded;
    }
    if (succeded) continueOnNextData();
    // notifyListeners();
  }

  void continueOnNextData() {
    var update = _lastTargetDataIndex + 1;
    if (update >= getDataSetOfCategory(category: _targetDataCategory).length) {
      update = 0;
    }
    _lastTargetDataIndex = update;
    notifyListeners();
  }

  void revertOnPreviousData() {
    var update = _lastTargetDataIndex - 1;
    if (update < 0) {
      update = getDataSetOfCategory(category: _targetDataCategory).length - 1;
    }
    _lastTargetDataIndex = update;
    notifyListeners();
  }

  List<TrainingSessionData> getDataSetOfCategory({String? category}) {
    category ??= targetDataCategory;
    return trainingSessionDataSet
        .where((element) => element.category == category)
        .toList();
  }

  TrainingSessionData getDataSet({String? category, required int index}) {
    final dataSetOfCategory =
        getDataSetOfCategory(category: category ?? targetDataCategory);
    return dataSetOfCategory[index];
  }

  void stopTrainingSession() {
    _duration = _lastTimeStarted;
    _started = false;
    notifyListeners();
  }

  void addResult({required SessionResult result, Function? setState}) {
    _sessionResults.add(result);
    notifyListeners();
  }

  List<String> datasetCategories() {
    final categories = <String>{};
    for (var data in trainingSessionDataSet) {
      categories.add(data.category);
    }
    return categories.toList();
  }
}
