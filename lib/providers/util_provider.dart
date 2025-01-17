import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final utilProvider = StateNotifierProvider<UtilNotifier, void>(
  (ref) => UtilNotifier(),
);

class UtilNotifier extends StateNotifier<void> {
  UtilNotifier() : super(null);

  // String型からDateTime型に変換する
  DateTime convertMonthToDateTime(String monthString) {
    // DateFormat で yyyy/MM 形式を指定
    DateFormat format = DateFormat('yyyy/MM');
    return format.parse(monthString);
  }

  // String型からDateTime型に変換する
  DateTime convertYearToDateTime(String yearString) {
    // DateFormat で yyyy/MM 形式を指定
    DateFormat format = DateFormat('yyyy');
    return format.parse(yearString);
  }

  // 現在の月から1ヶ月前のDateTime型を取得する
  DateTime getPrevMonth() {
    DateTime now = DateTime.now();
    // 月が0以下の場合、自動的に前年の12月に補正される
    return DateTime(now.year, now.month - 1, now.day);
  }

  // 現在の年から1年前のDateTime型を取得する
  DateTime getPrevYear() {
    DateTime now = DateTime.now();
    // 年が負の値になることはないが、補正される
    return DateTime(now.year - 1, now.month, now.day);
  }

  // int型から¥1,000の形式に変換する
  String convertToYenFormat({required int amount}) {
    return NumberFormat.currency(locale: 'ja_JP', symbol: '¥').format(amount);
  }

  int calcPrevTotalAmounts(int current, int prev) {
    return current - prev;
  }
}
