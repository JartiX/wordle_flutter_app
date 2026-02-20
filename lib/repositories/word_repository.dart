import 'package:flutter/services.dart';
import '../utils/word_repository_utils.dart';

class WordRepository {
  final int length;
   List<String>? _legalWords;

  WordRepository._({required this.length});

  static final Map<int, WordRepository> _instances = {};

  factory WordRepository(int length) {
    return _instances.putIfAbsent(
      length,
      () => WordRepository._(length: length),
    );
  }
List<String> get legalWords {
    if (_legalWords == null || _legalWords!.isEmpty) {
      throw Exception("Попытка доступа к словарю $length до загрузки!");
    }
    return _legalWords!;
  }
Future<void> load() async {
    if (_legalWords != null) return;

    try {
      final String wordsAsset = assetFor();
      final String wordsData = await rootBundle.loadString(wordsAsset);
      _legalWords = _parseWordsFromText(wordsData);
    } catch (e) {
      rethrow; 
    }
  }

  List<String> _parseWordsFromText(String text) {
    return text
        .split('\n')
        .map((word) => word.trim().toUpperCase())
        .where((word) => word.isNotEmpty)
        .toList();
  }
}
