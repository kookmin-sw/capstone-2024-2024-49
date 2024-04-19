import 'package:freezed_annotation/freezed_annotation.dart';

part 'Chat.freezed.dart';
part 'Chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String counsellorId,
    required String userId,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}