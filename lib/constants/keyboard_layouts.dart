import '../models/types.dart';

class KeyboardLayouts {
  static const String enterKey = 'ENTER';
  static const String deleteKey = 'DEL';

  static const Map<GameLanguage, List<List<String>>> layouts = {
    GameLanguage.ru: [
      ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
      ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
      ['Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', deleteKey],
      [enterKey]
    ],
    GameLanguage.en: [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', deleteKey],
      [enterKey]
    ],
  };
}
