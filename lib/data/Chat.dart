import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/converter.dart';

part 'Chat.freezed.dart';
part 'Chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String? chatId,
    required String counsellorId,
    required String userId,
    @TimestampConverter() required DateTime createdAt,
    required bool isClosed,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}