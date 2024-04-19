// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      counsellorId: json['counsellorId'] as String,
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      comment: json['comment'] as String,
      reply: json['reply'] as String,
      profileUrl: json['profileUrl'] as String?,
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'counsellorId': instance.counsellorId,
      'userId': instance.userId,
      'nickname': instance.nickname,
      'comment': instance.comment,
      'reply': instance.reply,
      'profileUrl': instance.profileUrl,
    };
