import '../models/settlement.dart';
import '../models/settlement_item.dart';
import '../utils/constants.dart';

class SettlementRepository {
  Future<Settlement> saveSettlement(Map<String, dynamic> settlementData) async {
    final response = await supabase
        .from('settlements')
        .insert(settlementData)
        .select()
        .single();

    if (response.isEmpty) {
      throw Exception('清算情報が取得できません');
    }

    return Settlement.fromMap(response);
  }

  Future<List<SettlementItem>> saveSettlementItems(
      List<Map<String, dynamic>> settlementItemData) async {
    final response = await supabase
        .from('settlement_items')
        .insert(settlementItemData)
        .select();

    if (response.isEmpty) {
      throw Exception('清算詳細情報が取得できません');
    }

    return (response as List<dynamic>)
        .map((item) => SettlementItem.fromMap(item))
        .toList();
  }

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
