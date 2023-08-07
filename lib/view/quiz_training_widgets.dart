import 'dart:async';

import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/extensions.dart';
import 'package:aphasia/view/shared_widgets.dart';
import 'package:aphasia/widgets_related_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizTrainingSessionWidget extends StatelessWidget {
  const QuizTrainingSessionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz session'),
      ),
      body: Consumer<TrainingSession>(
        builder: (_, trainingSession, __) {
          return trainingSession.currentData == null
              ? QuizTrainingStatisticsWidget(
                  trainingSession: trainingSession,
                )
              : const QuizWidget();
        },
      ),
    );
  }
}

class QuizTrainingStatisticsWidget extends StatelessWidget {
  final TrainingSession trainingSession;
  const QuizTrainingStatisticsWidget(
      {super.key, required this.trainingSession});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text("You are done 🤩🥳",
              style: Theme.of(context).textTheme.displayLarge),
          Text("SessionStat: --------- \n${trainingSession.stats}")
        ],
      ),
    );
  }
}

class UserGratificationActivator extends ChangeNotifier {
  bool? _userGotItRight;
  get userGotItRight => _userGotItRight;
  void gratifyUser() {
    _userGotItRight = true;
    notifyListeners();
  }

  void userGotItWrong() {
    _userGotItRight = false;
    notifyListeners();
  }

  void destroyGratification() {
    _userGotItRight = null;
    // notifyListeners();
  }
}

class QuizWidget extends StatelessWidget {
  const QuizWidget({super.key});
  List<String> choices(
      List<QuizTrainingData> dataset, QuizTrainingData answer) {
    final falseChoices = dataset
        .where((element) => element.id != answer.id)
        .toList()
        .sublist(0, 2);
    final List<QuizTrainingData> choices = List.from(falseChoices);
    choices.add(answer);
    return choices.map((option) => option.answer as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    final TrainingSession trainingSession = context.watch<TrainingSession>();
    QuizTrainingData? trainingData =
        trainingSession.currentData as QuizTrainingData?;
    return ChangeNotifierProvider(
        create: (context) => UserGratificationActivator(),
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Consumer<UserGratificationActivator>(
                      builder: (context, userGratificationActivator, child) {
                        return userGratificationActivator._userGotItRight ==
                                    null ||
                                userGratificationActivator._userGotItRight ==
                                    false
                            ? Text(
                                "${trainingSession.currentInstruction} ${userGratificationActivator._userGotItRight == false ? '😲' : '😇'}",
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              )
                            : CongratulationWidget(
                                answer: trainingData!,
                                onCountdownOver: trainingSession.nextData,
                                misses: trainingSession.answerStats.misses,
                                successes:
                                    trainingSession.answerStats.successes,
                              );
                      },
                    )),
                const SizedBox(
                  height: 25,
                ),
                Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.greenAccent, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      trainingData!.image,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                QuizUserInputListenerPad(
                  trainingData: trainingData,
                  choices: choices(
                    trainingSession.trainingDataset as List<QuizTrainingData>,
                    trainingData,
                  ),
                  inputValidator: trainingSession.validateUserAnswer,
                  nextData: trainingSession.nextData,
                ),
              ],
            ),
          );
        });
  }
}

typedef DatasetShuffler = List<String> Function(int);
typedef InputValidator = bool Function(String);
typedef DatasetIterator = void Function();

class QuizUserInputListenerPad extends StatefulWidget {
  final QuizTrainingData trainingData;
  final List<String> choices;
  final InputValidator inputValidator;
  final DatasetIterator nextData;
  const QuizUserInputListenerPad({
    super.key,
    required this.inputValidator,
    required this.choices,
    required this.nextData,
    required this.trainingData,
  });

  @override
  State<QuizUserInputListenerPad> createState() =>
      _QuizUserInputListenerPadState();
}

class _QuizUserInputListenerPadState extends State<QuizUserInputListenerPad> {
  var _micState = MicState.disabled;
  var _transcript = TranscriptState.ready.text;
  List<String>? _choices;

  @override
  void initState() {
    super.initState();
    _choices = widget.choices;
    _choices!.shuffle();
  }

  void shuffleChoices() {
    setState(() {
      widget.choices.shuffle();
      _choices = widget.choices;
    });
  }

  void notifyMicState(MicState micState) {
    setState(() {
      _micState = micState;
      if (_micState == MicState.done &&
          widget.inputValidator(_transcript.toLowerCase())) {
        _micState = MicState.disabled;
        _transcript = TranscriptState.ready.text;
        context.read<UserGratificationActivator>().gratifyUser();
      }
    });
  }

  void updateTranscript(String value) {
    setState(() {
      _transcript = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userGotitRight =
        context.watch<UserGratificationActivator>()._userGotItRight;
    if (_micState == MicState.done) {
      _micState = MicState.disabled;
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_micState == MicState.disabled)
            ...widget.choices.map((option) {
              final optionIsAnswer = option == widget.trainingData.answer;
              return SizedBox(
                height: 60,
                child: ElevatedButton(
                  style: userGotitRight == true
                      ? (ElevatedButton.styleFrom(
                          backgroundColor: optionIsAnswer
                              ? Colors.white
                              : Colors.greenAccent,
                        ))
                      : null,
                  child: Text(
                    '${option.capitalize()}${userGotitRight == true && optionIsAnswer ? " ✅🥳" : ""}',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: userGotitRight == true && !optionIsAnswer
                          ? Colors.black38
                          : theme.colorScheme.onPrimary,
                      fontSize: 25,
                      decoration: userGotitRight == true && !optionIsAnswer
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  onPressed: () async {
                    if (widget.inputValidator(option)) {
                      context.read<UserGratificationActivator>().gratifyUser();
                    } else {
                      context
                          .read<UserGratificationActivator>()
                          .userGotItWrong();
                      shuffleChoices();
                    }
                  },
                ),
              );
            }).toList()
          else
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _transcript,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontSize: 25,
                    color: Colors.black38,
                  ),
                ),
              ),
            ),
          RecordingMic(
            onMicStateChange: notifyMicState,
            onMicRecording: updateTranscript,
            onMicFinishedRecording: widget.inputValidator,
          )
        ],
      ),
    );
  }
}

typedef OnCountdownOver = void Function();

class CongratulationWidget extends StatefulWidget {
  final TrainingData answer;
  final int successes;
  final int misses;
  final OnCountdownOver onCountdownOver;

  const CongratulationWidget({
    super.key,
    required this.answer,
    required this.successes,
    required this.misses,
    required this.onCountdownOver,
  });
  @override
  State<CongratulationWidget> createState() => _CongratulationWidgetState();
}

class _CongratulationWidgetState extends State<CongratulationWidget> {
  var _countdownBeforeNextChallenge = 3;
  Timer? _timer;
  void decrementTimeOutBeforeNextChallenge() {
    setState(() {
      _countdownBeforeNextChallenge--;
    });
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _timer = timer;
      if (_countdownBeforeNextChallenge > 0) {
        decrementTimeOutBeforeNextChallenge();
      } else {
        _timer!.cancel();
        context.read<UserGratificationActivator>().destroyGratification();
        widget.onCountdownOver();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _timer != null && _timer!.isActive
        ? Center(
            child: Text(
              'Next question in $_countdownBeforeNextChallenge',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: Colors.black45),
            ),
          )
        : Center(
            child: Text(
              'Next question in 3',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: Colors.black45),
            ),
          );
  }
}

class OnWrongAnswerWidget extends StatelessWidget {
  const OnWrongAnswerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
