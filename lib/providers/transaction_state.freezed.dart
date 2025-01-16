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
  List<Transaction> get prevMonthTransactions =>
      throw _privateConstructorUsedError;
  List<Transaction> get prevYearTransactions =>
      throw _privateConstructorUsedError;
  List<Transaction> get sharedTransactions =>
      throw _privateConstructorUsedError;
  List<Transaction> get privateTransactions =>
      throw _privateConstructorUsedError;
  Map<TransactionType, double> get sharedTotalAmounts =>
      throw _privateConstructorUsedError;
  Map<TransactionType, double> get privateTotalAmounts =>
      throw _privateConstructorUsedError;
  List<String> get months => throw _privateConstructorUsedError;

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
      List<Transaction> prevMonthTransactions,
      List<Transaction> prevYearTransactions,
      List<Transaction> sharedTransactions,
      List<Transaction> privateTransactions,
      Map<TransactionType, double> sharedTotalAmounts,
      Map<TransactionType, double> privateTotalAmounts,
      List<String> months});
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
    Object? prevMonthTransactions = null,
    Object? prevYearTransactions = null,
    Object? sharedTransactions = null,
    Object? privateTransactions = null,
    Object? sharedTotalAmounts = null,
    Object? privateTotalAmounts = null,
    Object? months = null,
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
      prevMonthTransactions: null == prevMonthTransactions
          ? _value.prevMonthTransactions
          : prevMonthTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      prevYearTransactions: null == prevYearTransactions
          ? _value.prevYearTransactions
          : prevYearTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTransactions: null == sharedTransactions
          ? _value.sharedTransactions
          : sharedTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      privateTransactions: null == privateTransactions
          ? _value.privateTransactions
          : privateTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTotalAmounts: null == sharedTotalAmounts
          ? _value.sharedTotalAmounts
          : sharedTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      privateTotalAmounts: null == privateTotalAmounts
          ? _value.privateTotalAmounts
          : privateTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      months: null == months
          ? _value.months
          : months // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
      List<Transaction> prevMonthTransactions,
      List<Transaction> prevYearTransactions,
      List<Transaction> sharedTransactions,
      List<Transaction> privateTransactions,
      Map<TransactionType, double> sharedTotalAmounts,
      Map<TransactionType, double> privateTotalAmounts,
      List<String> months});
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
    Object? prevMonthTransactions = null,
    Object? prevYearTransactions = null,
    Object? sharedTransactions = null,
    Object? privateTransactions = null,
    Object? sharedTotalAmounts = null,
    Object? privateTotalAmounts = null,
    Object? months = null,
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
      prevMonthTransactions: null == prevMonthTransactions
          ? _value._prevMonthTransactions
          : prevMonthTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      prevYearTransactions: null == prevYearTransactions
          ? _value._prevYearTransactions
          : prevYearTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTransactions: null == sharedTransactions
          ? _value._sharedTransactions
          : sharedTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      privateTransactions: null == privateTransactions
          ? _value._privateTransactions
          : privateTransactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
      sharedTotalAmounts: null == sharedTotalAmounts
          ? _value._sharedTotalAmounts
          : sharedTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      privateTotalAmounts: null == privateTotalAmounts
          ? _value._privateTotalAmounts
          : privateTotalAmounts // ignore: cast_nullable_to_non_nullable
              as Map<TransactionType, double>,
      months: null == months
          ? _value._months
          : months // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$TransactionStateImpl implements _TransactionState {
  const _$TransactionStateImpl(
      {required this.isLoading,
      required final List<Transaction> transactions,
      required final List<Transaction> prevMonthTransactions,
      required final List<Transaction> prevYearTransactions,
      required final List<Transaction> sharedTransactions,
      required final List<Transaction> privateTransactions,
      required final Map<TransactionType, double> sharedTotalAmounts,
      required final Map<TransactionType, double> privateTotalAmounts,
      required final List<String> months})
      : _transactions = transactions,
        _prevMonthTransactions = prevMonthTransactions,
        _prevYearTransactions = prevYearTransactions,
        _sharedTransactions = sharedTransactions,
        _privateTransactions = privateTransactions,
        _sharedTotalAmounts = sharedTotalAmounts,
        _privateTotalAmounts = privateTotalAmounts,
        _months = months;

  @override
  final bool isLoading;
  final List<Transaction> _transactions;
  @override
  List<Transaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  final List<Transaction> _prevMonthTransactions;
  @override
  List<Transaction> get prevMonthTransactions {
    if (_prevMonthTransactions is EqualUnmodifiableListView)
      return _prevMonthTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prevMonthTransactions);
  }

  final List<Transaction> _prevYearTransactions;
  @override
  List<Transaction> get prevYearTransactions {
    if (_prevYearTransactions is EqualUnmodifiableListView)
      return _prevYearTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prevYearTransactions);
  }

  final List<Transaction> _sharedTransactions;
  @override
  List<Transaction> get sharedTransactions {
    if (_sharedTransactions is EqualUnmodifiableListView)
      return _sharedTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedTransactions);
  }

  final List<Transaction> _privateTransactions;
  @override
  List<Transaction> get privateTransactions {
    if (_privateTransactions is EqualUnmodifiableListView)
      return _privateTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_privateTransactions);
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

  final List<String> _months;
  @override
  List<String> get months {
    if (_months is EqualUnmodifiableListView) return _months;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_months);
  }

  @override
  String toString() {
    return 'TransactionState(isLoading: $isLoading, transactions: $transactions, prevMonthTransactions: $prevMonthTransactions, prevYearTransactions: $prevYearTransactions, sharedTransactions: $sharedTransactions, privateTransactions: $privateTransactions, sharedTotalAmounts: $sharedTotalAmounts, privateTotalAmounts: $privateTotalAmounts, months: $months)';
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
                .equals(other._prevMonthTransactions, _prevMonthTransactions) &&
            const DeepCollectionEquality()
                .equals(other._prevYearTransactions, _prevYearTransactions) &&
            const DeepCollectionEquality()
                .equals(other._sharedTransactions, _sharedTransactions) &&
            const DeepCollectionEquality()
                .equals(other._privateTransactions, _privateTransactions) &&
            const DeepCollectionEquality()
                .equals(other._sharedTotalAmounts, _sharedTotalAmounts) &&
            const DeepCollectionEquality()
                .equals(other._privateTotalAmounts, _privateTotalAmounts) &&
            const DeepCollectionEquality().equals(other._months, _months));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_prevMonthTransactions),
      const DeepCollectionEquality().hash(_prevYearTransactions),
      const DeepCollectionEquality().hash(_sharedTransactions),
      const DeepCollectionEquality().hash(_privateTransactions),
      const DeepCollectionEquality().hash(_sharedTotalAmounts),
      const DeepCollectionEquality().hash(_privateTotalAmounts),
      const DeepCollectionEquality().hash(_months));

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
      required final List<Transaction> prevMonthTransactions,
      required final List<Transaction> prevYearTransactions,
      required final List<Transaction> sharedTransactions,
      required final List<Transaction> privateTransactions,
      required final Map<TransactionType, double> sharedTotalAmounts,
      required final Map<TransactionType, double> privateTotalAmounts,
      required final List<String> months}) = _$TransactionStateImpl;

  @override
  bool get isLoading;
  @override
  List<Transaction> get transactions;
  @override
  List<Transaction> get prevMonthTransactions;
  @override
  List<Transaction> get prevYearTransactions;
  @override
  List<Transaction> get sharedTransactions;
  @override
  List<Transaction> get privateTransactions;
  @override
  Map<TransactionType, double> get sharedTotalAmounts;
  @override
  Map<TransactionType, double> get privateTotalAmounts;
  @override
  List<String> get months;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionStateImplCopyWith<_$TransactionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
