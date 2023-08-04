enum MicState {
  recording,
  done,
  disabled;
}

enum TranscriptState {
  ready('Listening for your answer...'),
  canceled('Release the mic and try again');

  final String text;
  const TranscriptState(this.text);
}
