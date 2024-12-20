import 'package:supabase_flutter/supabase_flutter.dart';

class SettlementService {
  late final SupabaseClient supabase;
  final Map<String, Map<String, dynamic>> _settlementCache = {};

  SettlementService(this.supabase);

  // get all settlement data
  Future<List<Map<String, dynamic>>> fetchAllData() async {
    final response = await supabase.from('settlements').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // get yearly settlement data
  Future<List<Map<String, dynamic>>?> fetchYearlyData(
      String groupId, DateTime date) async {
    final startOfYear = DateTime(date.year, 1, 1);
    final endOfYear = DateTime(date.year + 1, 1, 1);
    final data = await supabase
        .from('settlements')
        .select('*, settlement_items(*, profiles(username))')
        .eq('group_id', groupId)
        .gte('settlement_date', startOfYear.toIso8601String())
        .lt('settlement_date', endOfYear.toIso8601String())
        .order('settlement_date', ascending: true);
    return data as List<Map<String, dynamic>>?;
  }

  // upsert transaction data
  Future<PostgrestMap?> upsertData(Map<String, dynamic> data) async {
    await supabase.from('settlements').upsert({
      if (data['id'] != null) 'id': data['id'],
      ...data,
    });

    if (data['id'] != null) {
      final response = await supabase
          .from('settlements')
          .select('*, settlement_items(*, profiles(username))')
          .eq('id', data['id'])
          .maybeSingle();
      return response;
    }

    return null;
  }

  // delete transaction data
  Future<void> deleteData(int id) async {
    await supabase.from('settlement_items').delete().eq('settlement_id', id);
    await supabase.from('settlements').delete().eq('id', id);
  }

  void storeCache(String year, List<Map<String, dynamic>> data) {
    _settlementCache[year] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  List<Map<String, dynamic>>? loadCache(String year,
      {Duration expiry = const Duration(minutes: 15)}) {
    final cache = _settlementCache[year];
    if (cache != null) {
      final timestamp = cache['timestamp'] as DateTime?;
      // 有効期限内の場合のみデータを返す
      if (timestamp != null && DateTime.now().difference(timestamp) <= expiry) {
        return cache['data'] as List<Map<String, dynamic>>;
      }
    }
    return null;
  }

  void clearCache(String key) {
    _settlementCache.remove(key);
  }

  void clearAllCache() {
    _settlementCache.clear();
  }
}
