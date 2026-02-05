import 'package:cloud_firestore/cloud_firestore.dart';

class Case {
  final String id;
  final String caseNumber;
  final String plaintiffName;
  final String defendantName;
  final String courtLevel;
  final String bench;
  final String status;
  final DateTime nextHearingDate;
  final String? caseDetails;

  Case({
    required this.id,
    required this.caseNumber,
    required this.plaintiffName,
    required this.defendantName,
    required this.courtLevel,
    required this.bench,
    required this.status,
    required this.nextHearingDate,
    this.caseDetails,
  });

  factory Case.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Case(
      id: doc.id,
      caseNumber: data['caseNumber'] ?? '',
      plaintiffName: data['plaintiffName'] ?? '',
      defendantName: data['defendantName'] ?? '',
      courtLevel: data['courtLevel'] ?? '',
      bench: data['bench'] ?? '',
      status: data['status'] ?? '',
      nextHearingDate: (data['nextHearingDate'] as Timestamp).toDate(),
      caseDetails: data['caseDetails'],
    );
  }
}
