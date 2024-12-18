import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  late final SupabaseClient supabase;
  final Map<String, Map<String, dynamic>> _transactionCache = {};

  TransactionService(this.supabase);

  // get all transaction data
  Future<List<Map<String, dynamic>>> fetchAllData() async {
    final response = await supabase.from('transactions').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // get monthly transaction data
  Future<List<Map<String, dynamic>>?> fetchMonthlyData(
      String groupId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1)
        .subtract(const Duration(seconds: 1));
    final data = await supabase
        .from('transactions')
        .select('*, categories(id, name), profiles(username)')
        .gte('date', startOfMonth.toIso8601String())
        .lt('date', endOfMonth.toIso8601String())
        .eq('group_id', groupId)
        .order('date', ascending: false);
    return data as List<Map<String, dynamic>>?;
  }

  // upsert transaction data
  Future<PostgrestMap?> upsertData(Map<String, dynamic> data) async {
    await supabase.from('transactions').upsert({
      if (data['id'] != null) 'id': data['id'],
      ...data,
    });

    if (data['id'] != null) {
      final response = await supabase
          .from('transactions')
          .select('*, categories(id, name)')
          .eq('id', data['id'])
          .maybeSingle();
      return response;
    }

    return null;
  }

  // delete transaction data
  Future<void> deleteData(int id) async {
    await supabase.from('transactions').delete().eq('id', id);
  }

  Future<void> deleteAllData(String id) async {
    await supabase.from('transactions').delete().eq('profile_id', id);
  }

  void storeCache(String month, String type, List<Map<String, dynamic>> data) {
    _transactionCache[month] ??= {};
    _transactionCache[month]![type] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  List<Map<String, dynamic>>? loadCache(String month, String type,
      {Duration expiry = const Duration(minutes: 15)}) {
    final cache = _transactionCache[month];
    if (cache != null) {
      final timestamp = cache[type]['timestamp'] as DateTime?;
      // 有効期限内の場合のみデータを返す
      if (timestamp != null && DateTime.now().difference(timestamp) <= expiry) {
        return cache[type]['data'] as List<Map<String, dynamic>>;
      }
    }
    return null;
  }

  void clearCache(String key) {
    _transactionCache.remove(key);
  }

  void clearAllCache() {
    _transactionCache.clear();
  }
}
