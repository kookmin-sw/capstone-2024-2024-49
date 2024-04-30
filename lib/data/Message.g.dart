// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      sender: json['sender'] as String,
      text: json['text'] as String,
      image: json['image'] as String?,
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp?),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'text': instance.text,
      'image': instance.image,
      'timestamp': _$JsonConverterToJson<Timestamp?, DateTime>(
          instance.timestamp, const TimestampConverter().toJson),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);