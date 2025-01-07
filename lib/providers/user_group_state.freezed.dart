// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_group_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserGroupState {
  String? get inviteCode => throw _privateConstructorUsedError;
  Map<String, dynamic>? get group => throw _privateConstructorUsedError;

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGroupStateCopyWith<UserGroupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGroupStateCopyWith<$Res> {
  factory $UserGroupStateCopyWith(
          UserGroupState value, $Res Function(UserGroupState) then) =
      _$UserGroupStateCopyWithImpl<$Res, UserGroupState>;
  @useResult
  $Res call({String? inviteCode, Map<String, dynamic>? group});
}

/// @nodoc
class _$UserGroupStateCopyWithImpl<$Res, $Val extends UserGroupState>
    implements $UserGroupStateCopyWith<$Res> {
  _$UserGroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteCode = freezed,
    Object? group = freezed,
  }) {
    return _then(_value.copyWith(
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserGroupStateImplCopyWith<$Res>
    implements $UserGroupStateCopyWith<$Res> {
  factory _$$UserGroupStateImplCopyWith(_$UserGroupStateImpl value,
          $Res Function(_$UserGroupStateImpl) then) =
      __$$UserGroupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? inviteCode, Map<String, dynamic>? group});
}

/// @nodoc
class __$$UserGroupStateImplCopyWithImpl<$Res>
    extends _$UserGroupStateCopyWithImpl<$Res, _$UserGroupStateImpl>
    implements _$$UserGroupStateImplCopyWith<$Res> {
  __$$UserGroupStateImplCopyWithImpl(
      _$UserGroupStateImpl _value, $Res Function(_$UserGroupStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteCode = freezed,
    Object? group = freezed,
  }) {
    return _then(_$UserGroupStateImpl(
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      group: freezed == group
          ? _value._group
          : group // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$UserGroupStateImpl implements _UserGroupState {
  _$UserGroupStateImpl(
      {required this.inviteCode, required final Map<String, dynamic>? group})
      : _group = group;

  @override
  final String? inviteCode;
  final Map<String, dynamic>? _group;
  @override
  Map<String, dynamic>? get group {
    final value = _group;
    if (value == null) return null;
    if (_group is EqualUnmodifiableMapView) return _group;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'UserGroupState(inviteCode: $inviteCode, group: $group)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGroupStateImpl &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            const DeepCollectionEquality().equals(other._group, _group));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, inviteCode, const DeepCollectionEquality().hash(_group));

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGroupStateImplCopyWith<_$UserGroupStateImpl> get copyWith =>
      __$$UserGroupStateImplCopyWithImpl<_$UserGroupStateImpl>(
          this, _$identity);
}

abstract class _UserGroupState implements UserGroupState {
  factory _UserGroupState(
      {required final String? inviteCode,
      required final Map<String, dynamic>? group}) = _$UserGroupStateImpl;

  @override
  String? get inviteCode;
  @override
  Map<String, dynamic>? get group;

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGroupStateImplCopyWith<_$UserGroupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
