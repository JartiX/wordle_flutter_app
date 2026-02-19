import 'dart:collection';
import 'dart:math';
import 'types.dart';
import '../repositories/word_repository.dart';

class Word with IterableMixin<Letter> {
  Word(this._letters);
  static final WordRepository _repository = WordRepository();

  factory Word.empty() {
    return Word(List.filled(wordLength, (char: '', type: HitType.none)));
  }

  factory Word.fromString(String guess) {
    var list = guess.toUpperCase().split('');
    var letters = list
        .map((String char) => (char: char, type: HitType.none))
        .toList();
    return Word(letters);
  }

  factory Word.random() {
    var rand = Random();
    var nextWord = _repository.legalWords[rand.nextInt(_repository.legalWords.length)];
    return Word.fromString(nextWord);
  }

  factory Word.fromSeed(int seed) {
    return Word.fromString(_repository.legalWords[seed % _repository.legalWords.length]);
  }

  final List<Letter> _letters;

  List<Letter> get letters => _letters;

  @override
  Iterator<Letter> get iterator => _letters.iterator;

  @override
  bool get isEmpty {
    return every((letter) => letter.char.isEmpty);
  }

  @override
  bool get isNotEmpty => !isEmpty;

  Letter operator [](int i) => _letters[i];
  operator []=(int i, Letter value) => _letters[i] = value;

  @override
  String toString() {
    return _letters.map((Letter c) => c.char).join().trim();
  }

  String toStringVerbose() {
    return _letters.map((l) => '${l.char} - ${l.type.name}').join('\n');
  }
}