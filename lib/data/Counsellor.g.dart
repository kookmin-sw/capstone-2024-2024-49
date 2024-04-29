// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Counsellor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounsellorImpl _$$CounsellorImplFromJson(Map<String, dynamic> json) =>
    _$CounsellorImpl(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      comment: json['comment'] as String,
      notice: json['notice'] as String,
      chatCount: json['chatCount'] as int,
      reviewCount: json['reviewCount'] as int,
      profileUrl: json['profileUrl'] as String?,
    );

Map<String, dynamic> _$$CounsellorImplToJson(_$CounsellorImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'comment': instance.comment,
      'notice': instance.notice,
      'chatCount': instance.chatCount,
      'reviewCount': instance.reviewCount,
      'profileUrl': instance.profileUrl,
    };