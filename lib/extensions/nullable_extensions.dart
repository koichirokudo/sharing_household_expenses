import 'package:intl/intl.dart';

extension NullableIntExtensions on double? {
  String toYenFormat() {
    return NumberFormat.currency(locale: 'ja_JP', symbol: '¥')
        .format(this?.round() ?? 0);
  }

  int toSafeInt() {
    return this?.toInt() ?? 0;
  }
}
