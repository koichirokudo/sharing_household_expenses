import 'package:sharing_household_expenses/models/transaction.dart';

import '../utils/constants.dart';

class TransactionRepository {
  //　月ごとのトランザクションを取得する
  Future<List<Transaction>> fetchMonthlyByGroup(
      String groupId, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month);
    final endOfMonth = DateTime(date.year, date.month + 1)
        .subtract(const Duration(seconds: 1));

    final response = await supabase
        .from('transactions')
        .select('*, categories!inner(*), profiles!inner(*)')
        .gte('date', startOfMonth.toIso8601String())
        .lt('date', endOfMonth.toIso8601String())
        .eq('group_id', groupId)
        .order('date', ascending: false);

    return (response as List<dynamic>)
        .map((transaction) => Transaction.fromMap(transaction))
        .toList();
  }

  Future<List<Transaction>> fetchMonthlyBySettlement(
      String settlementId) async {
    final response = await supabase
        .from('transactions')
        .select('*, categories!inner(*), profiles!inner(*)')
        .eq('settlement_id', settlementId)
        .order('date', ascending: false);

    return (response as List<dynamic>)
        .map((transaction) => Transaction.fromMap(transaction))
        .toList();
  }

  // トランザクションを追加
  Future<Transaction> insert(Map<String, dynamic> transaction) async {
    final response = await supabase
        .from('transactions')
        .insert(transaction)
        .select()
        .single();
    return Transaction.fromMap(response);
  }

  Future<Transaction?> update(transaction) async {
    final response =
        await supabase.functions.invoke('update-transaction', body: {
      'transaction': transaction,
    });

    Map<String, dynamic> updatedTransaction = {};
    if (response.data['success'] == true) {
      updatedTransaction = response.data['transaction'];
    }
    return Transaction.fromMap(updatedTransaction);
  }

  // トランザクションを更新
  Future<List<Transaction>> upsert(transactions) async {
    final response =
        await supabase.from('transactions').upsert(transactions).select();
    return (response as List<dynamic>)
        .map((transaction) => Transaction.fromMap(transaction))
        .toList();
  }

  // トランザクションを削除
  Future<void> delete(int id) async {
    await supabase.from('transactions').delete().eq('id', id);
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
