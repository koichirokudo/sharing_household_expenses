import '../utils/constants.dart';

class SettlementRepository {
  Future<bool> checkSettlement(String visibility, String month) async {
    final response = await supabase.functions.invoke(
      'check-settlement',
      body: {
        'visibility': visibility,
        'month': month.isNotEmpty ? month : null,
      },
    );

    return response.data['isSettlement'] ?? false;
  }
}
