// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'Counsellor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Counsellor _$CounsellorFromJson(Map<String, dynamic> json) {
  return _Counsellor.fromJson(json);
}

/// @nodoc
mixin _$Counsellor {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  int get chatCount => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  String? get profileUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CounsellorCopyWith<Counsellor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounsellorCopyWith<$Res> {
  factory $CounsellorCopyWith(
          Counsellor value, $Res Function(Counsellor) then) =
      _$CounsellorCopyWithImpl<$Res, Counsellor>;
  @useResult
  $Res call(
      {String userId,
      String nickname,
      String comment,
      int chatCount,
      int reviewCount,
      String? profileUrl});
}

/// @nodoc
class _$CounsellorCopyWithImpl<$Res, $Val extends Counsellor>
    implements $CounsellorCopyWith<$Res> {
  _$CounsellorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? comment = null,
    Object? chatCount = null,
    Object? reviewCount = null,
    Object? profileUrl = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      chatCount: null == chatCount
          ? _value.chatCount
          : chatCount // ignore: cast_nullable_to_non_nullable
              as int,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CounsellorImplCopyWith<$Res>
    implements $CounsellorCopyWith<$Res> {
  factory _$$CounsellorImplCopyWith(
          _$CounsellorImpl value, $Res Function(_$CounsellorImpl) then) =
      __$$CounsellorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String nickname,
      String comment,
      int chatCount,
      int reviewCount,
      String? profileUrl});
}

/// @nodoc
class __$$CounsellorImplCopyWithImpl<$Res>
    extends _$CounsellorCopyWithImpl<$Res, _$CounsellorImpl>
    implements _$$CounsellorImplCopyWith<$Res> {
  __$$CounsellorImplCopyWithImpl(
      _$CounsellorImpl _value, $Res Function(_$CounsellorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? comment = null,
    Object? chatCount = null,
    Object? reviewCount = null,
    Object? profileUrl = freezed,
  }) {
    return _then(_$CounsellorImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      chatCount: null == chatCount
          ? _value.chatCount
          : chatCount // ignore: cast_nullable_to_non_nullable
              as int,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      profileUrl: freezed == profileUrl
          ? _value.profileUrl
          : profileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CounsellorImpl implements _Counsellor {
  const _$CounsellorImpl(
      {required this.userId,
      required this.nickname,
      required this.comment,
      required this.chatCount,
      required this.reviewCount,
      this.profileUrl});

  factory _$CounsellorImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounsellorImplFromJson(json);

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final String comment;
  @override
  final int chatCount;
  @override
  final int reviewCount;
  @override
  final String? profileUrl;

  @override
  String toString() {
    return 'Counsellor(userId: $userId, nickname: $nickname, comment: $comment, chatCount: $chatCount, reviewCount: $reviewCount, profileUrl: $profileUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounsellorImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.chatCount, chatCount) ||
                other.chatCount == chatCount) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.profileUrl, profileUrl) ||
                other.profileUrl == profileUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, nickname, comment,
      chatCount, reviewCount, profileUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CounsellorImplCopyWith<_$CounsellorImpl> get copyWith =>
      __$$CounsellorImplCopyWithImpl<_$CounsellorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CounsellorImplToJson(
      this,
    );
  }
}

abstract class _Counsellor implements Counsellor {
  const factory _Counsellor(
      {required final String userId,
      required final String nickname,
      required final String comment,
      required final int chatCount,
      required final int reviewCount,
      final String? profileUrl}) = _$CounsellorImpl;

  factory _Counsellor.fromJson(Map<String, dynamic> json) =
      _$CounsellorImpl.fromJson;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  String get comment;
  @override
  int get chatCount;
  @override
  int get reviewCount;
  @override
  String? get profileUrl;
  @override
  @JsonKey(ignore: true)
  _$$CounsellorImplCopyWith<_$CounsellorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
