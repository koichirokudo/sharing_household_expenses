import 'package:sharing_household_expenses/models/transaction.dart';

import '../utils/constants.dart';

class TransactionRepository {
  //　月ごとのトランザクションを取得する
  Future<List<Transaction>> fetchMonthly(String groupId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1)
        .subtract(const Duration(seconds: 1));

    final response = await supabase
        .from('transactions')
        .select('*, sub_categories!inner(*), profiles!inner(*)')
        .gte('date', startOfMonth.toIso8601String())
        .lt('date', endOfMonth.toIso8601String())
        .eq('group_id', groupId)
        .order('date', ascending: false);

    return (response as List<dynamic>)
        .map((transaction) => Transaction.fromMap(transaction))
        .toList();
  }

  // トランザクションを追加
  Future<void> insert(Transaction transaction) async {
    final data = transaction.toMap();
    final response = await supabase.from('transactions').insert(data);

    if (response.error != null) {
      throw Exception(
          'Failed to insert transaction: ${response.error!.message}');
    }
  }

  // トランザクションを更新
  Future<void> update(Transaction transaction) async {
    final data = transaction.toMap();
    final response = await supabase.from('transactions').update(data);

    if (response.error != null) {
      throw Exception(
          'Failed to update transaction: ${response.error!.message}');
    }
  }

  // トランザクションを削除
  Future<void> delete(int id) async {
    final response = await supabase.from('transactions').delete().eq('id', id);

    if (response.error != null) {
      throw Exception(
          'Failed to delete transaction: ${response.error!.message}');
    }
  }

  // ユーザーに紐づくトランザクションを削除
  Future<void> deleteByProfile(String id) async {
    final response =
        await supabase.from('transactions').delete().eq('profile_id', id);

    if (response.error != null) {
      throw Exception(
          'Failed to delete transactions by profile: ${response.error!.message}');
    }
  }
}
