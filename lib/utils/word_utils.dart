import '../models/word.dart';
import '../models/types.dart';
import '../repositories/word_repository.dart';

extension WordUtils on Word {
   
  bool get isLegalGuess {
    if (!WordRepository().allLegalGuesses.contains(toString())) {
      return false;
    }

    return true;
  }

  Word evaluateGuess(Word other) {
    for (var i = 0; i < length; i++) {
      if (other[i].char == this[i].char) {
        this[i] = (char: this[i].char, type: HitType.hit);
        other[i] = (char: other[i].char, type: HitType.removed);
      }
    }

    for (var i = 0; i < other.length; i++) {

      Letter targetLetter = other[i];
      if (targetLetter.type != HitType.none) continue;

      for (var j = 0; j < length; j++) {
        Letter guessedLetter = this[j];
        if (guessedLetter.type != HitType.none) continue;

        if (guessedLetter.char == targetLetter.char) {
          this[j] = (char: guessedLetter.char, type: HitType.partial);
          other[i] = (char: targetLetter.char, type: HitType.removed);
          break;
        }
      }
    }

    for (var i = 0; i < length; i++) {
      if (this[i].type == HitType.none) {
        this[i] = (char: this[i].char, type: HitType.miss);
      }
    }

    return this;
  }
}