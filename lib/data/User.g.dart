// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: json['userId'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
      isCounsellor: json['isCounsellor'] as bool,
      profileUrl: json['profileUrl'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'password': instance.password,
      'nickname': instance.nickname,
      'isCounsellor': instance.isCounsellor,
      'profileUrl': instance.profileUrl,
    };
