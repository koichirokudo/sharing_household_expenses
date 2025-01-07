import '../utils/constants.dart';

class SettlementRepository {
  Future<bool> checkSettlement(bool share, String month) async {
    final response = await supabase.functions.invoke(
      'check-settlement',
      body: {
        'share': share.toString(),
        'month': month.isNotEmpty ? month : null,
      },
    );

    return response.data['isSettlement'] ?? false;
  }
}
