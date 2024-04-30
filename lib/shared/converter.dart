import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:luckymoon/core/logger.dart';

class TimestampConverter implements JsonConverter<DateTime, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp? timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }

    return timestamp.toDate();
  }

  @override
  Timestamp? toJson(DateTime date) {
     return Timestamp.fromDate(date);
  }
}