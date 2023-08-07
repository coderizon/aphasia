import 'package:aphasia/domain/models/training.dart';
import 'package:aphasia/enums/training_enum.dart';
import 'package:aphasia/extensions.dart';
import 'package:aphasia/service_locator.dart';
import 'package:aphasia/widgets_related_enum.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

nextPage(BuildContext context, Widget nextPage) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return nextPage;
    }),
  );
}

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

class TrainingTypePickerWidget extends StatelessWidget {
  final TrainingType trainingType;
  final Function? onTap;
  const TrainingTypePickerWidget({
    required this.trainingType,
    this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50, // Set the desired radius for the avatar
                    backgroundImage: NetworkImage(trainingType.image),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      trainingType.name.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                trainingType.description.capitalize(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(_UnimplementedAction.snackBar);
        }
      },
    );
  }
}

typedef OnCategoryPicked = Function(List<TrainingData>);

class TrainingDatasetCategoryPickerWidget extends StatelessWidget {
  final Future<List<TrainingData>> dataset;
  final OnCategoryPicked? onTap;
  const TrainingDatasetCategoryPickerWidget({
    required this.dataset,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
        future: dataset,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            throw (snapshot.stackTrace!, snapshot.error!);
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Loading Training dataset...',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
              ),
            );
          }

          final List<TrainingData> dataset = snapshot.data;
          final Set<String> categories = dataset.map((e) => e.category).toSet();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Category picker'),
            ),
            body: ListView(
              children: categories
                  .map(
                    (category) => ListTile(
                        title: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Set the border radius
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
                                begin: Alignment
                                    .topLeft, // Set the starting point of the gradient
                                end: Alignment
                                    .bottomCenter, // Set the ending point of the gradient
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary,
                                  theme.colorScheme.background
                                ], // Set the colors for the gradient
                              ),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius:
                                              50, // Set the desired radius for the avatar
                                          backgroundImage: NetworkImage(
                                              'https://images.unsplash.com/photo-1522543558187-768b6df7c25c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80'),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          category.toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'description'.capitalize(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        onTap: () {
                          if (onTap != null) {
                            onTap!(
                              dataset
                                  .where(
                                    (element) => element.category == category,
                                  )
                                  .toList(),
                            );
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(_UnimplementedAction.snackBar);
                          }
                        }),
                  )
                  .toList(),
            ),
          );
        });
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

