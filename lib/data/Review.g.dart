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
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp?),
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'counsellorId': instance.counsellorId,
      'userId': instance.userId,
      'nickname': instance.nickname,
      'comment': instance.comment,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };