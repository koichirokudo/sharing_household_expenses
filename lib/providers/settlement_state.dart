import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/settlement.dart';

part 'settlement_state.freezed.dart';

@freezed
class SettlementState with _$SettlementState {
  const factory SettlementState({
    required bool isSettlement,
    required List<Settlement> settlements,
  }) = _SettlementState;
}
