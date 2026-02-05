import 'package:cloud_firestore/cloud_firestore.dart';

class Bench {
  final String id;
  final String courtLevel;
  final String benchName;

  Bench({required this.id, required this.courtLevel, required this.benchName});

  factory Bench.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Bench(
      id: doc.id,
      courtLevel: data['courtLevel'] ?? '',
      benchName: data['benchName'] ?? '',
    );
  }
}
