import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/service_locator.dart';
import 'package:aphasia/widgets_related_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract class _UnimplementedAction {
  static const snackBar = SnackBar(
    content: Text('Unimplemented action!'),
    // action: SnackBarAction(
    //   label: 'Undo',
    //   onPressed: () {
    //     // Some code to undo the change.
    //   },
    // ),
  );
}

class TrainingDatasetOverviewWidget extends StatelessWidget {
  final TrainingDataset trainingDataset;
  final Function? onTap;
  const TrainingDatasetOverviewWidget({
    required this.trainingDataset,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final overview = trainingDataset.overview;
    return ListTile(
      title: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Set the border radius
          side: const BorderSide(
            color: Colors.black, // Set the border color
            width: 2.5, // Set the border width
          ),
        ),
        borderOnForeground: true,
        color: Theme.of(context).colorScheme.primary,
        surfaceTintColor: Colors.purple,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50, // Set the desired radius for the avatar
                  backgroundImage: NetworkImage(overview.cover),
                ),
                const SizedBox(width: 20),
                Text(
                  "QUIZ",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              overview.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ]),
      ),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(_UnimplementedAction.snackBar);
        }
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) {
        //     return TrainingDatasetCategoriesListWidget();
        //   }),
        // );
      },
    );
  }
}

class TrainingDatasetCategoryOverviewWidget extends StatelessWidget {
  final TrainingDatasetCategoryOverview overview;
  final Function? onTap;
  const TrainingDatasetCategoryOverviewWidget({
    required this.overview,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        title: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Set the border radius
            side: const BorderSide(
              color: Colors.black, // Set the border color
              width: 2.5, // Set the border width
            ),
          ),
          borderOnForeground: true,
          color: Theme.of(context).colorScheme.primary,
          surfaceTintColor: (Colors.amberAccent),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin:
                    Alignment.topLeft, // Set the starting point of the gradient
                end: Alignment
                    .bottomCenter, // Set the ending point of the gradient
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary,
                  theme.colorScheme.background
                ], // Set the colors for the gradient
              ),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50, // Set the desired radius for the avatar
                      backgroundImage: NetworkImage(overview.cover),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      overview.name.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  overview.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ]),
          ),
        ),
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(_UnimplementedAction.snackBar);
          }
        });
  }
}

abstract class TrainingSessionWidget extends StatelessWidget {
  final TrainingSession trainingSession;
  TrainingSessionWidget({
    super.key,
    required this.trainingSession,
  }) {
    trainingSession.start();
  }

  Widget wrapInNotifierProvider({required Widget child}) {
    return ChangeNotifierProvider.value(
      value: trainingSession,
      child: child,
    );
  }
}

typedef OnMicStateChange = void Function(MicState);
typedef OnMicRecording = void Function(String);
typedef OnMicFinishedRecording = bool Function(String);
typedef OnMicCanceledRecording = void Function();

class RecordingMic extends StatefulWidget {
  final OnMicStateChange onMicStateChange;
  final OnMicRecording onMicRecording;
  final OnMicFinishedRecording onMicFinishedRecording;
  final OnMicCanceledRecording? onMicCanceledRecording;
  const RecordingMic({
    super.key,
    required this.onMicStateChange,
    required this.onMicRecording,
    required this.onMicFinishedRecording,
    this.onMicCanceledRecording,
  });

  @override
  State<StatefulWidget> createState() {
    return _RecordingMicState();
  }
}

// class MicInteraction extends ChangeNotifier {
//   var _micState = MicState.disabled;
//   var _transcript = TranscriptState.ready.text;

//   void notifyMicState(MicState micState) {
//     setState(() {
//       _micState = micState;
//       if (_micState == MicState.done &&
//           widget.inputValidator(_transcript.toLowerCase())) {
//         _micState = MicState.disabled;
//         _transcript = TranscriptState.ready.text;
//         widget.nextData();
//       }
//     });
//   }

//   void updateTranscript(String value) {
//     setState(() {
//       _transcript = value;
//     });
//   }
// }
class _RecordingMicState extends State<RecordingMic> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final speechToText = serviceLocator<SpeechToText>();
    return GestureDetector(
      onTapDown: (_) async {
        if (!_isRecording) {
          var available = await speechToText.initialize();
          if (available) {
            setState(() {
              _isRecording = true;
              widget.onMicStateChange(MicState.recording);
            });
            speechToText.listen(onResult: (result) {
              widget.onMicRecording(result.recognizedWords);
            });
          }
        }
      },
      onTapUp: (_) {
        setState(() {
          _isRecording = false;
          widget.onMicStateChange(MicState.done);
        });
      },
      onTapCancel: () {
        setState(() {
          _isRecording = false;
        });
        speechToText.stop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording ? Colors.white : Colors.grey,
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isRecording ? Icons.mic : Icons.mic_off,
          size: 35,
          color: _isRecording
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

// Use the RecordingMic widget in your app:
// RecordingMic(),

