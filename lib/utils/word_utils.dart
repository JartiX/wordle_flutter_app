import '../models/word.dart';
import '../models/types.dart';
import '../repositories/word_repository.dart';

extension WordUtils on Word {
  bool get isLegalGuess {
    return WordRepository(length).legalWords.contains(toString());
  }

  Word evaluateGuess(Word other) {
    for (var i = 0; i < length; i++) {
      if (other[i].char == this[i].char) {
        this[i].type = HitType.hit;
        other[i].type = HitType.removed;
      }
    }

    for (var i = 0; i < other.length; i++) {
      if (other[i].type != HitType.none) continue;
      for (var j = 0; j < length; j++) {
        if (this[j].type != HitType.none) continue;
        if (this[j].char == other[i].char) {
          this[j].type = HitType.partial;
          other[i].type = HitType.removed;
          break;
        }
      }
    }

    for (var i = 0; i < length; i++) {
      if (this[i].type == HitType.none) {
        this[i].type = HitType.miss;
      }
    }

    return this;
  }
}