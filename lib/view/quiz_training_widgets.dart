import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/extensions.dart';
import 'package:aphasia/service_locator.dart';
import 'package:aphasia/view/shared_widgets.dart';
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
          return trainingSession.currentData == null
              ? QuizTrainingStatisticsWidget(
                  trainingSession: trainingSession,
                )
              : QuizWidget(
                  trainingSession: trainingSession,
                );
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

class QuizWidget extends StatelessWidget {
  final QuizTrainingSession trainingSession;
  const QuizWidget({super.key, required this.trainingSession});

  @override
  Widget build(BuildContext context) {
    // final QuizTrainingSession trainingSession =
    //     context.watch<TrainingSession>() as QuizTrainingSession;
    QuizTrainingData? trainingData =
        trainingSession.currentData as QuizTrainingData?;
    return trainingData == null
        ? const Text('Done')
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "${trainingSession.currentInstruction} 🧐",
                      style: Theme.of(context).textTheme.headlineMedium,
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
                    side: const BorderSide(color: Colors.greenAccent, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        20), // Adjust the same border radius as the Card's shape
                    child: Image.network(
                      trainingData.image,
                      height: 250,
                      fit: BoxFit
                          .cover, // Ensure the image fills the entire Card
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
                ),
              ],
            ),
          );
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
  const QuizUserInputListenerPad({
    super.key,
    required this.datasetShuffler,
    required this.inputValidator,
    required this.nextData,
    required this.trainingData,
  });

  @override
  State<QuizUserInputListenerPad> createState() =>
      _QuizUserInputListenerPadState();
}

class _QuizUserInputListenerPadState extends State<QuizUserInputListenerPad> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shuffledPossibilities = widget.datasetShuffler(2);
    shuffledPossibilities.shuffle();
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                          await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Fun fact about this fruit',
                                      style: theme.textTheme.headlineMedium),
                                  insetPadding: const EdgeInsets.all(8),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          widget.trainingData.funFact,
                                          style: theme.textTheme.bodyLarge,
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'Next challenge',
                                        style: theme.textTheme.displaySmall!
                                            .copyWith(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          widget.nextData();
                                        });
                                      },
                                    )
                                  ],
                                );
                              });
                        } else {
                          setState(() {
                            // trigger shuffled
                          });
                        }
                      },
                    ),
                  ))
              .toList(),
          const RecordingMic()
        ],
      ),
    );
  }
}
