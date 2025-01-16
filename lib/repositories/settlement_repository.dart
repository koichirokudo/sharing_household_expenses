import '../models/settlement.dart';
import '../models/settlement_item.dart';
import '../utils/constants.dart';

class SettlementRepository {
  Future<List<Settlement>> fetchYearly(String groupId, DateTime now) async {
    final startOfYear = '${now.year}/01';
    final endOfYear = '${now.year + 1}/01';

    final response = await supabase
        .from('settlements')
        .select('*, settlement_items(*, profiles(*))')
        .eq('group_id', groupId)
        .gte('settlement_date', startOfYear)
        .lt('settlement_date', endOfYear)
        .order('settlement_date', ascending: true);

    return (response as List<dynamic>)
        .map((settlement) => Settlement.fromMap(settlement))
        .toList();
  }

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

    return response.map((item) => SettlementItem.fromMap(item)).toList();
  }

  Future<Map<String, dynamic>> checkSettlement(
      String visibility, String month) async {
    final response = await supabase.functions.invoke(
      'check-settlement',
      body: {
        'visibility': visibility,
        'month': month.isNotEmpty ? month : null,
      },
    );

    return response.data;
  }
}
