import 'package:cloud_firestore/cloud_firestore.dart';

class ExposureModel {
  final String uid;
  final DateTime date; // exact time of exposure
  final double uvIndex;
  final double exposureTime; // in minutes or seconds
  final DateTime timestamp;  // added to support ordering

  ExposureModel({
    required this.uid,
    required this.date,
    required this.uvIndex,
    required this.exposureTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'date': Timestamp.fromDate(date),
        'uvIndex': uvIndex,
        'exposureTime': exposureTime,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory ExposureModel.fromJson(Map<String, dynamic> map) => ExposureModel(
        uid: map['uid'],
        date: (map['date'] as Timestamp).toDate(),
        uvIndex: (map['uvIndex'] ?? 0).toDouble(),
        exposureTime: (map['exposureTime'] ?? 0).toDouble(),
        timestamp: (map['timestamp'] as Timestamp).toDate(),
      );
}
