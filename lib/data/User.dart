import 'package:freezed_annotation/freezed_annotation.dart';

part 'User.freezed.dart';
part 'User.g.dart'; // JSON 직렬화를 위한 코드를 생성합니다.

@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String password,
    required String nickname,
    required bool isCounsellor,
    String? profileUrl, // 옵셔널 필드
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}