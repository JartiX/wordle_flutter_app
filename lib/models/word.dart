import 'dart:collection';
import 'dart:math';
import 'types.dart';
import '../repositories/word_repository.dart';

class Word with IterableMixin<Letter> {
  Word(this._letters, this._wordLength);

  final List<Letter> _letters;
  final int _wordLength;

  static WordRepository repository(int length) => WordRepository(length);

  factory Word.empty(int length) {
    return Word(
      List.generate(length, (_) => Letter(char: '', type: HitType.none)),
      length,
    );
  }

  factory Word.fromString(String guess) {
    var list = guess.toUpperCase().split('');
    var letters = list
        .map((String char) => Letter(char: char, type: HitType.none))
        .toList();
    return Word(letters, letters.length);
  }

  factory Word.random(int length) {
    var rand = Random();
    var repo = repository(length);
    var nextWord = repo.legalWords[rand.nextInt(repo.legalWords.length)];
    return Word.fromString(nextWord);
  }

  factory Word.fromSeed(int seed, int length) {
    var repo = repository(length);
    return Word.fromString(
      repo.legalWords[seed % repo.legalWords.length],
    );
  }

  List<Letter> get letters => _letters;
  int get wordLength => _wordLength;

  @override
  Iterator<Letter> get iterator => _letters.iterator;

  @override
  bool get isEmpty => every((letter) => letter.char.isEmpty);
  @override
  bool get isNotEmpty => !isEmpty;

  Letter operator [](int i) => _letters[i];
  operator []=(int i, Letter value) => _letters[i] = value;

  @override
  String toString() => _letters.map((l) => l.char).join();
  String toStringVerbose() => _letters.map((l) => '${l.char} - ${l.type.name}').join('\n');
}