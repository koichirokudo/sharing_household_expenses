import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/settlement_state.dart';
import 'package:sharing_household_expenses/repositories/settlement_repository.dart';

final settlementProvider =
    StateNotifierProvider<SettlementNotifier, SettlementState>(
  (ref) => SettlementNotifier(SettlementRepository()),
);

class SettlementNotifier extends StateNotifier<SettlementState> {
  final SettlementRepository repository;

  SettlementNotifier(this.repository)
      : super(
          SettlementState(
            settlements: [],
          ),
        );

  Future<bool> checkSettlement(String visibility, String month) async {
    try {
      final response = await repository.checkSettlement(visibility, month);
      return response;
    } catch (e) {
      throw Exception('Failed to check settlement: $e');
    }
  }
}
