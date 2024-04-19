import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Counsellor.freezed.dart';
part 'Counsellor.g.dart'; // JSON 직렬화를 위한 코드를 생성합니다.

@freezed
class Counsellor with _$Counsellor {
  const factory Counsellor({
    required String userId,
    required String nickname,
    required String comment,
    required int chatCount,
    required int reviewCount,
    String? profileUrl, // 옵셔널 필드
  }) = _Counsellor;

  factory Counsellor.fromJson(Map<String, dynamic> json) => _$CounsellorFromJson(json);
}