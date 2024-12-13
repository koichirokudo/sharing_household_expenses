import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, Map<String, dynamic>> transactionCache = {};

class TransactionService {
  late final SupabaseClient supabase;
  TransactionService(this.supabase);

  // get all transaction data
  Future<List<Map<String, dynamic>>> fetchAllData() async {
    final response = await supabase.from('transactions').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // get monthly transaction data
  Future<List<Map<String, dynamic>>?> fetchMonthlyData(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1)
        .subtract(const Duration(seconds: 1));
    final data = await supabase
        .from('transactions')
        .select('*, categories(id, name)')
        .gte('date', startOfMonth.toIso8601String())
        .lt('date', endOfMonth.toIso8601String())
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

  void storeCache(String month, List<Map<String, dynamic>> data) {
    transactionCache[month] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  List<Map<String, dynamic>>? loadCache(String month,
      {Duration expiry = const Duration(minutes: 15)}) {
    final cache = transactionCache[month];
    if (cache != null) {
      final timestamp = cache['timestamp'] as DateTime;
      // 有効期限内の場合のみデータを返す
      if (DateTime.now().difference(timestamp) <= expiry) {
        return cache['data'] as List<Map<String, dynamic>>;
      }
    }
    return null;
  }

  void clearCache(String key) {
    transactionCache.remove(key);
  }

  void clearAllCache() {
    transactionCache.clear();
  }
}
