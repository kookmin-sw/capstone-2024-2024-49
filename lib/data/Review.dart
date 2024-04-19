import 'package:freezed_annotation/freezed_annotation.dart';

part 'Review.freezed.dart';
part 'Review.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String counsellorId,
    required String userId,
    required String nickname,
    required String comment,
    required String reply,
    String? profileUrl,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
