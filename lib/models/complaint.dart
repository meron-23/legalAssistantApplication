import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String fullName;
  final String email;
  final String subject;
  final String description;
  final DateTime? timestamp;

  Complaint({
    required this.fullName,
    required this.email,
    required this.subject,
    required this.description,
    this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'subject': subject,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
