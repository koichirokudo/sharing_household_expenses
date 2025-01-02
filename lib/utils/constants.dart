import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
final unexpectedErrorMessage = '予期せぬエラーが発生しました';

final circularIndicator = const Center(
  child: CircularProgressIndicator(),
);

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

String convertToYenFormat({required int amount}) {
  return NumberFormat.currency(locale: 'ja_JP', symbol: '¥').format(amount);
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showSnackBarError({
    required String message,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }
}
