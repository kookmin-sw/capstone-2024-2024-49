import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/converter.dart';

part 'Review.freezed.dart';
part 'Review.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required String counsellorId,
    required String userId,
    required String nickname,
    required String comment,
    @TimestampConverter() required DateTime timestamp,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}