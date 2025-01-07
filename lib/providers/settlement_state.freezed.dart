// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettlementState {
  bool get isSettlement => throw _privateConstructorUsedError;

  List<Settlement> get settlements => throw _privateConstructorUsedError;

  /// Create a copy of SettlementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementStateCopyWith<SettlementState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementStateCopyWith<$Res> {
  factory $SettlementStateCopyWith(
          SettlementState value, $Res Function(SettlementState) then) =
      _$SettlementStateCopyWithImpl<$Res, SettlementState>;

  @useResult
  $Res call({bool isSettlement, List<Settlement> settlements});
}

/// @nodoc
class _$SettlementStateCopyWithImpl<$Res, $Val extends SettlementState>
    implements $SettlementStateCopyWith<$Res> {
  _$SettlementStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettlementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSettlement = null,
    Object? settlements = null,
  }) {
    return _then(_value.copyWith(
      isSettlement: null == isSettlement
          ? _value.isSettlement
          : isSettlement // ignore: cast_nullable_to_non_nullable
              as bool,
      settlements: null == settlements
          ? _value.settlements
          : settlements // ignore: cast_nullable_to_non_nullable
              as List<Settlement>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementStateImplCopyWith<$Res>
    implements $SettlementStateCopyWith<$Res> {
  factory _$$SettlementStateImplCopyWith(_$SettlementStateImpl value,
          $Res Function(_$SettlementStateImpl) then) =
      __$$SettlementStateImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({bool isSettlement, List<Settlement> settlements});
}

/// @nodoc
class __$$SettlementStateImplCopyWithImpl<$Res>
    extends _$SettlementStateCopyWithImpl<$Res, _$SettlementStateImpl>
    implements _$$SettlementStateImplCopyWith<$Res> {
  __$$SettlementStateImplCopyWithImpl(
      _$SettlementStateImpl _value, $Res Function(_$SettlementStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettlementState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSettlement = null,
    Object? settlements = null,
  }) {
    return _then(_$SettlementStateImpl(
      isSettlement: null == isSettlement
          ? _value.isSettlement
          : isSettlement // ignore: cast_nullable_to_non_nullable
              as bool,
      settlements: null == settlements
          ? _value._settlements
          : settlements // ignore: cast_nullable_to_non_nullable
              as List<Settlement>,
    ));
  }
}

/// @nodoc

class _$SettlementStateImpl implements _SettlementState {
  const _$SettlementStateImpl(
      {required this.isSettlement, required final List<Settlement> settlements})
      : _settlements = settlements;

  @override
  final bool isSettlement;
  final List<Settlement> _settlements;

  @override
  List<Settlement> get settlements {
    if (_settlements is EqualUnmodifiableListView) return _settlements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_settlements);
  }

  @override
  String toString() {
    return 'SettlementState(isSettlement: $isSettlement, settlements: $settlements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementStateImpl &&
            (identical(other.isSettlement, isSettlement) ||
                other.isSettlement == isSettlement) &&
            const DeepCollectionEquality()
                .equals(other._settlements, _settlements));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSettlement,
      const DeepCollectionEquality().hash(_settlements));

  /// Create a copy of SettlementState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementStateImplCopyWith<_$SettlementStateImpl> get copyWith =>
      __$$SettlementStateImplCopyWithImpl<_$SettlementStateImpl>(
          this, _$identity);
}

abstract class _SettlementState implements SettlementState {
  const factory _SettlementState(
      {required final bool isSettlement,
      required final List<Settlement> settlements}) = _$SettlementStateImpl;

  @override
  bool get isSettlement;

  @override
  List<Settlement> get settlements;

  /// Create a copy of SettlementState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementStateImplCopyWith<_$SettlementStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
