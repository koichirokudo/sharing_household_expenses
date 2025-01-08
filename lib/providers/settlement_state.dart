import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/settlement.dart';
import '../models/settlement_item.dart';

part 'settlement_state.freezed.dart';

@freezed
class SettlementState with _$SettlementState {
  const factory SettlementState({
    required List<Settlement> settlements,
    required List<SettlementItem> settlementItems,
  }) = _SettlementState;
}
