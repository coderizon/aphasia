enum TrainingType {
  quiz(
    'description',
    'https://images.unsplash.com/photo-1508179522353-11ba468c4a1c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTEwfHxwZW9wbGV8ZW58MHwwfDB8fHwy&auto=format&fit=crop&w=500&q=60',
  );
  // matching(
  //   'description',
  //   'https://images.unsplash.com/photo-1508179522353-11ba468c4a1c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTEwfHxwZW9wbGV8ZW58MHwwfDB8fHwy&auto=format&fit=crop&w=500&q=60',
  // ),
  // patternRecognition(
  //   'description',
  //   'https://images.unsplash.com/photo-1508179522353-11ba468c4a1c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTEwfHxwZW9wbGV8ZW58MHwwfDB8fHwy&auto=format&fit=crop&w=500&q=60',
  // ),
  // puzzle(
  //   'description',
  //   'https://images.unsplash.com/photo-1508179522353-11ba468c4a1c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTEwfHxwZW9wbGV8ZW58MHwwfDB8fHwy&auto=format&fit=crop&w=500&q=60',
  // ),
  // clozeText(
  //   'description',
  //   'https://images.unsplash.com/photo-1508179522353-11ba468c4a1c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTEwfHxwZW9wbGV8ZW58MHwwfDB8fHwy&auto=format&fit=crop&w=500&q=60',
  // );

  final String description;
  final String image;

  const TrainingType(this.description, this.image);
}

enum TrainingSessionState {
  listening,
  stopped,
  neverStarted;
}

enum TrainingSessionException {
  listening,
  noCurrentData,
  notListening,
  stopped,
  neverStarted;
}

enum ImageSource {
  www,
  local;
}
