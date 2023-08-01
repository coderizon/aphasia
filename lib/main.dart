import 'package:aphasia/image_association_training_models.dart';
import 'package:aphasia/training_session_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Aphasia());
}

class Aphasia extends StatelessWidget {
  const Aphasia({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aphasia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu),
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final availableTrainingSessions = <TrainingSession>[
    ImageWordAssociationSession(),
  ];

  Widget buildTrainingSessionOverview({
    required BuildContext context,
    required TrainingSession trainingSession,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(bottom: 15),
      title: Center(
        child: Text(
          trainingSession.title.toUpperCase(),
          style: const TextStyle(fontSize: 30),
        ),
      ),
      dense: true,
      tileColor: Colors.amber,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingSessionDataSetCategoriesWidget(
              trainingSession: trainingSession,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page = GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(20),
      children: availableTrainingSessions
          .map(
            (trainingSession) => buildTrainingSessionOverview(
              context: context,
              trainingSession: trainingSession,
            ),
          )
          .toList(),
    );
    return page;
  }
}

class TrainingSessionDataSetCategoriesWidget extends StatelessWidget {
  // In the constructor, require a Todo.
  const TrainingSessionDataSetCategoriesWidget(
      {super.key, required this.trainingSession});

  // Declare a field that holds the Todo.
  final TrainingSession trainingSession;

  Widget buildSubcategoryOverview({
    required BuildContext context,
    required String category,
    required TrainingSession trainingSession,
  }) {
    return ListTile(
      textColor: Colors.white,
      contentPadding: const EdgeInsets.all(10),
      title: Center(
        child: Text(
          category.toUpperCase(),
          style: const TextStyle(fontSize: 30),
        ),
      ),
      dense: true,
      tileColor: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunningTrainingSession(
              trainingSession: trainingSession,
              targetDataCategory: category,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    final trainingDataSetCategories = trainingSession.datasetCategories();
    return Scaffold(
        appBar: AppBar(
          title: Text(trainingSession.title.toUpperCase()),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: trainingDataSetCategories.length,
          itemBuilder: (BuildContext context, int index) {
            return buildSubcategoryOverview(
              context: context,
              category: trainingDataSetCategories[index],
              trainingSession: trainingSession,
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ));
  }
}

class RunningTrainingSession extends StatelessWidget {
  // In the constructor, require a Todo.
  const RunningTrainingSession({
    required this.trainingSession,
    required this.targetDataCategory,
    super.key,
  });

  // Declare a field that holds the Todo.
  final TrainingSession trainingSession;
  final String targetDataCategory;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    trainingSession.resetLastTargetDataIndex();
    return ChangeNotifierProvider.value(
      value: trainingSession,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                '${targetDataCategory.toUpperCase()} ${trainingSession.title.toUpperCase()} ${'Session'.toUpperCase()}'),
          ),
          body: trainingSession.startSession(
            context: context,
            targetDataCategory: targetDataCategory,
          ),
        );
      },
    );
  }
}
