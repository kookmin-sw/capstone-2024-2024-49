import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/converter.dart';

part 'Message.freezed.dart';
part 'Message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String sender,
    required String text,
    String? image,
    @TimestampConverter() required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
