import '../repositories/word_repository.dart';
import '../constants/assets.dart';

extension WordRepositoryUtils on WordRepository {
  String assetFor() {
    switch (length) {
      case 5:
        return Assets.legalWords5;
      case 6:
        return Assets.legalWords6;
      case 7:
        return Assets.legalWords7;
      case 8:
        return Assets.legalWords8;
      default:
        throw Exception("Неподдерживаемая длина слова");
    }
  }
}
