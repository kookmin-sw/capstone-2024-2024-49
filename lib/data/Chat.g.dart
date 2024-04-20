// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatImpl _$$ChatImplFromJson(Map<String, dynamic> json) => _$ChatImpl(
      chatId: json['chatId'] as String?,
      counsellorId: json['counsellorId'] as String,
      userId: json['userId'] as String,
      isClosed: json['isClosed'] as bool,
    );

Map<String, dynamic> _$$ChatImplToJson(_$ChatImpl instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'counsellorId': instance.counsellorId,
      'userId': instance.userId,
      'isClosed': instance.isClosed,
    };