import 'package:freezed_annotation/freezed_annotation.dart';

part 'Counsellor.freezed.dart';
part 'Counsellor.g.dart';

@freezed
class Counsellor with _$Counsellor {
  const factory Counsellor({
    required String userId,
    required String nickname,
    required String comment,
    required String notice,
    required int chatCount,
    required int reviewCount,
    String? profileUrl,
  }) = _Counsellor;

  factory Counsellor.fromJson(Map<String, dynamic> json) => _$CounsellorFromJson(json);
}