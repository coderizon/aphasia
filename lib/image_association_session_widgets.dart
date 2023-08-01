import 'package:aphasia/training_session_models.dart';
import 'package:aphasia/utils.dart';
import 'package:aphasia/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget getImageWordAssociationSessionWidget({required BuildContext context}) {
  final trainingSession = context.watch<TrainingSession>();
  final dataSet =
      trainingSession.getDataSet(index: trainingSession.lastTargetDataIndex);
  final category = DataCategory.values.singleWhere(
    (element) => element.value == dataSet.category,
  );
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          category.question,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Container(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
              child: switch (dataSet.imageUnit) {
            ImageUnit.letter => generateLetterContainer(dataSet.name),
            ImageUnit.pixel => SizedBox(
                height: 200,
                width: 500,
                child: Image.network(dataSet.imageSrc, fit: BoxFit.cover),
              )
          }),
        ),
        _getUserInputListernerWidget(
          context: context,
          trainingSession: trainingSession,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => trainingSession.revertOnPreviousData(),
                icon: const Icon(Icons.skip_previous),
                iconSize: 40),
            IconButton(
                onPressed: () => trainingSession.continueOnNextData(),
                icon: const Icon(Icons.skip_next),
                iconSize: 40)
          ],
        )
      ],
    ),
  );
}

Widget _getUserInputListernerWidget({
  required BuildContext context,
  required TrainingSession trainingSession,
}) {
  final dataSet = trainingSession.getDataSet(
    index: trainingSession.lastTargetDataIndex,
  );
  final options = dataSet.imageUnit == ImageUnit.letter
      ? generateGermanAlphabet()
      : trainingSession.getDataSetOfCategory().map((e) => e.name).toList();
  final isLettersCategory =
      trainingSession.targetDataCategory == DataCategory.letters.value;
  final numberOfElementToGenerate = isLettersCategory ? 6 : 5;
  final choices = generateRandomListWithLetter(
    options,
    numberOfElementToGenerate,
    dataSet.name,
  );
  choices.shuffle();
  return wrapInColumn(choices, trainingSession);
}

GridView wrapInGridView(List<String> choices, TrainingSession trainingSession) {
  return GridView.count(
    crossAxisCount: 4,
    children: getListOfChoices(choices, trainingSession),
  );
}

Column wrapInColumn(List<String> choices, TrainingSession trainingSession) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: getListOfChoices(choices, trainingSession),
  );
}

List<ListTile> getListOfChoices(
  List<String> choices,
  TrainingSession trainingSession,
) {
  return choices
      .map((e) => ListTile(
            title: generateLetterContainer(e),
            dense: true,
            onTap: () => trainingSession.listenUserInput(userInput: e),
          ))
      .toList();
}
