// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TransactionState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<Transaction> get transactions => throw _privateConstructorUsedError;
  Map<TransactionType, double> get sharedTotalAmounts =>
      throw _privateConstructorUsedError;
  Map<TransactionType, double> get privateTotalAmounts =>
      throw _privateConstructorUsedError;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionStateCopyWith<TransactionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionStateCopyWith<$Res> {
  factory $TransactionStateCopyWith(
          TransactionState value, $Res Function(TransactionState) then) =
      _$TransactionStateCopyWithImpl<$Res, TransactionState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<Transaction> transactions,
      Map<TransactionType, double> sharedTotalAmounts,
      Map<TransactionType, double> privateTotalAmounts});
}

/// @nodoc
class _$TransactionStateCopyWithImpl<$Res, $Val extends TransactionState>
    implements $TransactionStateCopyWith<$Res> {
  _$TransactionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? transactions = null,
    Object? sharedTotalAmounts = null,
    Object? privateTotalAmounts = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTotalAmounts: null == sharedTotalAmounts
          ? _value.sharedTotalAmounts
          : sharedTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      privateTotalAmounts: null == privateTotalAmounts
          ? _value.privateTotalAmounts
          : privateTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionStateImplCopyWith<$Res>
    implements $TransactionStateCopyWith<$Res> {
  factory _$$TransactionStateImplCopyWith(_$TransactionStateImpl value,
          $Res Function(_$TransactionStateImpl) then) =
      __$$TransactionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<Transaction> transactions,
      Map<TransactionType, double> sharedTotalAmounts,
      Map<TransactionType, double> privateTotalAmounts});
}

/// @nodoc
class __$$TransactionStateImplCopyWithImpl<$Res>
    extends _$TransactionStateCopyWithImpl<$Res, _$TransactionStateImpl>
    implements _$$TransactionStateImplCopyWith<$Res> {
  __$$TransactionStateImplCopyWithImpl(_$TransactionStateImpl _value,
      $Res Function(_$TransactionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? transactions = null,
    Object? sharedTotalAmounts = null,
    Object? privateTotalAmounts = null,
  }) {
    return _then(_$TransactionStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTotalAmounts: null == sharedTotalAmounts
          ? _value._sharedTotalAmounts
          : sharedTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      privateTotalAmounts: null == privateTotalAmounts
          ? _value._privateTotalAmounts
          : privateTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
    ));
  }
}

/// @nodoc

class _$TransactionStateImpl implements _TransactionState {
  const _$TransactionStateImpl(
      {required this.isLoading,
      required final List<Transaction> transactions,
      required final Map<TransactionType, double> sharedTotalAmounts,
      required final Map<TransactionType, double> privateTotalAmounts})
      : _transactions = transactions,
        _sharedTotalAmounts = sharedTotalAmounts,
        _privateTotalAmounts = privateTotalAmounts;

  @override
  final bool isLoading;
  final List<Transaction> _transactions;
  @override
  List<Transaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final Map<TransactionType, double> _sharedTotalAmounts;
  @override
  Map<TransactionType, double> get sharedTotalAmounts {
    if (_sharedTotalAmounts is EqualUnmodifiableMapView)
      return _sharedTotalAmounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sharedTotalAmounts);
  }

  final Map<TransactionType, double> _privateTotalAmounts;
  @override
  Map<TransactionType, double> get privateTotalAmounts {
    if (_privateTotalAmounts is EqualUnmodifiableMapView)
      return _privateTotalAmounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_privateTotalAmounts);
  }

  @override
  String toString() {
    return 'TransactionState(isLoading: $isLoading, transactions: $transactions, sharedTotalAmounts: $sharedTotalAmounts, privateTotalAmounts: $privateTotalAmounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality()
                .equals(other._sharedTotalAmounts, _sharedTotalAmounts) &&
            const DeepCollectionEquality()
                .equals(other._privateTotalAmounts, _privateTotalAmounts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_sharedTotalAmounts),
      const DeepCollectionEquality().hash(_privateTotalAmounts));

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionStateImplCopyWith<_$TransactionStateImpl> get copyWith =>
      __$$TransactionStateImplCopyWithImpl<_$TransactionStateImpl>(
          this, _$identity);
}

abstract class _TransactionState implements TransactionState {
  const factory _TransactionState(
          {required final bool isLoading,
          required final List<Transaction> transactions,
          required final Map<TransactionType, double> sharedTotalAmounts,
          required final Map<TransactionType, double> privateTotalAmounts}) =
      _$TransactionStateImpl;

  @override
  bool get isLoading;
  @override
  List<Transaction> get transactions;
  @override
  Map<TransactionType, double> get sharedTotalAmounts;
  @override
  Map<TransactionType, double> get privateTotalAmounts;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionStateImplCopyWith<_$TransactionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
