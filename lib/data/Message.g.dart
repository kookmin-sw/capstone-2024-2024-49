// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      sender: json['sender'] as String,
      text: json['text'] as String,
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'text': instance.text,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };