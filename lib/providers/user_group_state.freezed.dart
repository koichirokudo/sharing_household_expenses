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
  bool get isLoading => throw _privateConstructorUsedError;
  String? get inviteCode => throw _privateConstructorUsedError;
  UserGroup? get group => throw _privateConstructorUsedError;

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
  $Res call({bool isLoading, String? inviteCode, UserGroup? group});
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
    Object? isLoading = null,
    Object? inviteCode = freezed,
    Object? group = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as UserGroup?,
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
  $Res call({bool isLoading, String? inviteCode, UserGroup? group});
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
    Object? isLoading = null,
    Object? inviteCode = freezed,
    Object? group = freezed,
  }) {
    return _then(_$UserGroupStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as UserGroup?,
    ));
  }
}

/// @nodoc

class _$UserGroupStateImpl implements _UserGroupState {
  _$UserGroupStateImpl(
      {required this.isLoading, required this.inviteCode, required this.group});

  @override
  final bool isLoading;
  @override
  final String? inviteCode;
  @override
  final UserGroup? group;

  @override
  String toString() {
    return 'UserGroupState(isLoading: $isLoading, inviteCode: $inviteCode, group: $group)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGroupStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.group, group) || other.group == group));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, inviteCode, group);

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
      {required final bool isLoading,
      required final String? inviteCode,
      required final UserGroup? group}) = _$UserGroupStateImpl;

  @override
  bool get isLoading;
  @override
  String? get inviteCode;
  @override
  UserGroup? get group;

  /// Create a copy of UserGroupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGroupStateImplCopyWith<_$UserGroupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
