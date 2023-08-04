import 'package:aphasia/domain/models/quiz_training.dart';
import 'package:aphasia/service_locator.dart';
import 'package:aphasia/view/quiz_training_widgets.dart';
import 'package:aphasia/view/shared_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  setup();
  runApp(const Aphasia());
}

class Aphasia extends StatelessWidget {
  const Aphasia({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.white;
    // const Color backgroundColor = Color.fromARGB(255, 110, 228, 199);
    const Color backgroundColor = Colors.greenAccent;
    const ColorScheme customColorScheme = ColorScheme(
      primary: primaryColor,
      secondary: Colors.deepPurple,
      surface: Colors.white,
      background: backgroundColor,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    );
    const customTextTheme = TextTheme(
      displayLarge: TextStyle(
          fontSize: 72, fontWeight: FontWeight.bold, color: Colors.black),
      displayMedium: TextStyle(
          fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
      displaySmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
      headlineLarge: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w500, color: Colors.black),
      headlineMedium: TextStyle(
          fontSize: 25, fontWeight: FontWeight.w500, color: Colors.black),
      headlineSmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      titleLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
      titleMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
      titleSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 20, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 18, color: Colors.black),
      bodySmall: TextStyle(fontSize: 16, color: Colors.grey),
      labelLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
    );

    return MaterialApp(
      title: 'Aphasia',
      theme: ThemeData(
        colorScheme: customColorScheme,
        textTheme: customTextTheme,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Choose a method of training"),
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: serviceLocator.allReady(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Builder(
              builder: (context) {
                final quizTrainingDataset =
                    serviceLocator<QuizTrainingDataset>();
                return ListView(
                  children: [
                    TrainingDatasetOverviewWidget(
                        trainingDataset: quizTrainingDataset,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return QuizTrainingDatasetCategoryPicker(
                                trainingDatasetCategories:
                                    quizTrainingDataset.categories.cast(),
                              );
                            }),
                          );
                        })
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            throw (snapshot.stackTrace!, snapshot.error!);
          } else {
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
        });
  }
}
