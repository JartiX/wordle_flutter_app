import 'package:flutter/services.dart';
import '../constants/assets.dart';

class WordRepository {
  late final List<String> legalWords;
  late final List<String> legalGuesses;
  late final Set<String> allLegalGuesses;

  WordRepository._();

  static final WordRepository _instance = WordRepository._();

  factory WordRepository() => _instance;

  Future<void> load() async {
    final String wordsData = await rootBundle.loadString(Assets.legalWords);
    legalWords = _parseWordsFromText(wordsData);

    final String guessesData = await rootBundle.loadString(Assets.legalGuesses);
    legalGuesses = _parseWordsFromText(guessesData);

    allLegalGuesses = {...legalWords, ...legalGuesses};
  }

  List<String> _parseWordsFromText(String text) {
    return text
        .split('\n')
        .map((word) => word.trim().toUpperCase())
        .where((word) => word.isNotEmpty)
        .toList();
  }
}
