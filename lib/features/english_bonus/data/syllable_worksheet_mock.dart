import 'syllable_worksheet_word.dart';

/// 原型数据：接口就绪后改为按 [sheetId]（如 yyyyMMdd）请求后台
class SyllableWorksheetMock {
  SyllableWorksheetMock._();

  /// 固定 15 词；后续可 `GET /syllable-sheet/{sheetId}` 替换
  static List<SyllableWorksheetWord> wordsForSheet(String sheetId) {
    return List<SyllableWorksheetWord>.from(_kDefault15);
  }

  static const List<SyllableWorksheetWord> _kDefault15 = [
    SyllableWorksheetWord(
      word: 'interesting',
      phonetic: '/ˈɪntrəstɪŋ/',
      definition: 'adj. 有趣的',
    ),
    SyllableWorksheetWord(
      word: 'tomato',
      phonetic: '/təˈmɑːtəʊ/',
      definition: 'n. 西红柿',
    ),
    SyllableWorksheetWord(
      word: 'rainbow',
      phonetic: '/ˈreɪnbəʊ/',
      definition: 'n. 彩虹',
    ),
    SyllableWorksheetWord(
      word: 'elephant',
      phonetic: '/ˈelɪfənt/',
      definition: 'n. 大象',
    ),
    SyllableWorksheetWord(
      word: 'beautiful',
      phonetic: '/ˈbjuːtɪfl/',
      definition: 'adj. 美丽的',
    ),
    SyllableWorksheetWord(
      word: 'computer',
      phonetic: '/kəmˈpjuːtə(r)/',
      definition: 'n. 计算机',
    ),
    SyllableWorksheetWord(
      word: 'family',
      phonetic: '/ˈfæməli/',
      definition: 'n. 家庭',
    ),
    SyllableWorksheetWord(
      word: 'butterfly',
      phonetic: '/ˈbʌtəflaɪ/',
      definition: 'n. 蝴蝶',
    ),
    SyllableWorksheetWord(
      word: 'wonderful',
      phonetic: '/ˈwʌndəfl/',
      definition: 'adj. 精彩的',
    ),
    SyllableWorksheetWord(
      word: 'adventure',
      phonetic: '/ədˈventʃə(r)/',
      definition: 'n. 冒险',
    ),
    SyllableWorksheetWord(
      word: 'chocolate',
      phonetic: '/ˈtʃɒklət/',
      definition: 'n. 巧克力',
    ),
    SyllableWorksheetWord(
      word: 'exercise',
      phonetic: '/ˈeksəsaɪz/',
      definition: 'n. 锻炼',
    ),
    SyllableWorksheetWord(
      word: 'dictionary',
      phonetic: '/ˈdɪkʃənri/',
      definition: 'n. 词典',
    ),
    SyllableWorksheetWord(
      word: 'celebrate',
      phonetic: '/ˈselɪbreɪt/',
      definition: 'v. 庆祝',
    ),
    SyllableWorksheetWord(
      word: 'together',
      phonetic: '/təˈɡeðə(r)/',
      definition: 'adv. 一起',
    ),
  ];
}
