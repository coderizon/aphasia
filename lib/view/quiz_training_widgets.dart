import 'dart:async';

import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/extensions.dart';
import 'package:aphasia/service_locator.dart';
import 'package:aphasia/view/shared_widgets.dart';
import 'package:aphasia/widgets_related_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizTrainingDatasetCategoryPicker extends StatelessWidget {
  final List<QuizTrainingDatasetCategory> trainingDatasetCategories;
  const QuizTrainingDatasetCategoryPicker({
    super.key,
    required this.trainingDatasetCategories,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a category to train on'),
      ),
      body: ListView(
        children: trainingDatasetCategories
            .map(
              (category) => TrainingDatasetCategoryOverviewWidget(
                overview: category.overview,
                onTap: () {
                  initializeQuizSession(
                    context,
                    category,
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void initializeQuizSession(
    BuildContext context,
    TrainingDatasetCategory trainingDatasetCategory,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        final trainingSession = serviceLocator<QuizTrainingSession>(
            param1: trainingDatasetCategory);
        return Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("New training session"),
              ),
              body: QuizTrainingSessionWidget(
                trainingSession: trainingSession,
              ),
            );
          },
        );
      }),
    );
  }
}

class QuizTrainingSessionWidget extends TrainingSessionWidget {
  QuizTrainingSessionWidget({
    super.key,
    required super.trainingSession,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: trainingSession,
        builder: (context, child) {
          final QuizTrainingSession trainingSession =
              context.watch<TrainingSession>() as QuizTrainingSession;

          if (trainingSession.currentData == null) {
            return QuizTrainingStatisticsWidget(
              trainingSession: trainingSession,
            );
          } else {
            return QuizWidget(
              trainingSession: trainingSession,
            );
          }
        });
  }
}

class QuizTrainingStatisticsWidget extends StatelessWidget {
  final QuizTrainingSession trainingSession;
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
  var _userGotItRight = false;
  get userGotItRight => _userGotItRight;
  void gratifyUser() {
    _userGotItRight = true;
    notifyListeners();
  }

  void destroyGratification() {
    _userGotItRight = false;
    // notifyListeners();
  }
}

class QuizWidget extends StatelessWidget {
  final QuizTrainingSession trainingSession;
  const QuizWidget({super.key, required this.trainingSession});

  @override
  Widget build(BuildContext context) {
    QuizTrainingData? trainingData =
        trainingSession.currentData as QuizTrainingData?;
    return ChangeNotifierProvider(
        create: (context) => UserGratificationActivator(),
        builder: (context, child) {
          final userGratificationActivator =
              context.watch<UserGratificationActivator>();
          if (!userGratificationActivator.userGotItRight) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        "${trainingSession.currentInstruction} 🧐",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:
                          const BorderSide(color: Colors.greenAccent, width: 4),
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
                    datasetShuffler: trainingSession.shuffleTrainingDataset,
                    inputValidator: trainingSession.validateUserAnswer,
                    nextData: trainingSession.nextData,
                    userGratificationActivator: userGratificationActivator,
                  ),
                ],
              ),
            );
          } else {
            return CongratulationWidget(
              answer: trainingData!,
              onCountdownOver: trainingSession.nextData,
              misses: trainingSession.answerStats.misses,
              successes: trainingSession.answerStats.successes,
            );
          }
        });
  }
}

typedef DatasetShuffler = List<String> Function(int);
typedef InputValidator = bool Function(String);
typedef DatasetIterator = TrainingData? Function();

class QuizUserInputListenerPad extends StatefulWidget {
  final QuizTrainingData trainingData;
  final DatasetShuffler datasetShuffler;
  final InputValidator inputValidator;
  final DatasetIterator nextData;
  final UserGratificationActivator userGratificationActivator;
  const QuizUserInputListenerPad({
    super.key,
    required this.datasetShuffler,
    required this.inputValidator,
    required this.nextData,
    required this.trainingData,
    required this.userGratificationActivator,
  });

  @override
  State<QuizUserInputListenerPad> createState() =>
      _QuizUserInputListenerPadState();
}

class _QuizUserInputListenerPadState extends State<QuizUserInputListenerPad> {
  var _micState = MicState.disabled;
  var _transcript = TranscriptState.ready.text;

  void notifyMicState(MicState micState) {
    setState(() {
      _micState = micState;
      if (_micState == MicState.done &&
          widget.inputValidator(_transcript.toLowerCase())) {
        _micState = MicState.disabled;
        _transcript = TranscriptState.ready.text;
        widget.userGratificationActivator.gratifyUser();
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
    final shuffledPossibilities = widget.datasetShuffler(2);
    if (_micState == MicState.done) {
      _micState = MicState.disabled;
    }
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_micState == MicState.disabled)
            ...shuffledPossibilities
                .map((e) => SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        child: Text(e.capitalize(),
                            style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 25)),
                        onPressed: () async {
                          if (widget.inputValidator(e)) {
                            widget.userGratificationActivator.gratifyUser();
                          } else {
                            setState(() {
                              // trigger shuffled
                            });
                          }
                        },
                      ),
                    ))
                .toList()
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

typedef OnCountdownOver = TrainingData? Function();

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
  var _countdownBeforeNextChallenge = 8;
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Text(
                "✅ 😎 Yeah! Scroll to read more 💚!",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Image.network(
            (widget.answer as QuizTrainingData).image,
            height: 250,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  if (_timer != null) {
                    setState(() {
                      _timer!.cancel();
                    });
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text(
                    (widget.answer as QuizTrainingData).funFact,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          if (_timer != null && _timer!.isActive)
            Center(
              child: Text(
                'Next question in $_countdownBeforeNextChallenge seconds',
              ),
            )
          else
            const Center(
              child: Text(
                'No rush! Take your time!🥰',
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                _timer!.cancel();
                context
                    .read<UserGratificationActivator>()
                    .destroyGratification();
                widget.onCountdownOver();
              },
              child: Text(
                'Continue quiz',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
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
