List<String> generateGermanAlphabet() {
  List<String> germanAlphabet = [];

  // Lowercase letters (a to z)
  for (int codePoint = 97; codePoint <= 122; codePoint++) {
    germanAlphabet.add(String.fromCharCode(codePoint));
  }

  // Umlauts (ä, ö, ü) and 'ß'
  germanAlphabet.add(String.fromCharCode(228)); // ä
  germanAlphabet.add(String.fromCharCode(246)); // ö
  germanAlphabet.add(String.fromCharCode(252)); // ü
  germanAlphabet.add(String.fromCharCode(223)); // ß

  return germanAlphabet;
}

List<String> generateRandomListWithLetter(
  List<String> from,
  int x,
  String targetLetter,
) {
  List<String> allLetters = from;
  List<String> randomList = [];

  // Filter out letters that match the target letter
  List<String> lettersWithTargetLetter =
      allLetters.where((letter) => letter == targetLetter).toList();

  // If the target letter is present in the alphabet, add it to the random list
  if (lettersWithTargetLetter.isNotEmpty) {
    randomList.add(lettersWithTargetLetter.first);
  }

  // Remove the target letter from the original list to prevent duplicates
  allLetters.remove(targetLetter);

  // Shuffle the remaining letters to make the selection random
  allLetters.shuffle();

  // Pick x-1 random letters from the shuffled list
  randomList.addAll(allLetters.take(x - 1));

  // Shuffle the final random list to randomize the order
  randomList.shuffle();

  return randomList;
}
