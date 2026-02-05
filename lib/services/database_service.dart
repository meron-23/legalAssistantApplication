import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case.dart';
import '../models/announcement.dart';
import '../models/bench.dart';
import '../models/complaint.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of announcements
  Stream<List<Announcement>> getAnnouncements() {
    return _db
        .collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Announcement.fromFirestore(doc))
              .toList(),
        );
  }

  // Fetch benches for a specific court level
  Future<List<Bench>> getBenches(String courtLevel) async {
    var snapshot = await _db
        .collection('benches')
        .where('courtLevel', isEqualTo: courtLevel)
        .get();
    return snapshot.docs.map((doc) => Bench.fromFirestore(doc)).toList();
  }

  // Search cases
  Future<List<Case>> searchCases({
    required String courtLevel,
    required String bench,
    required String searchTerm,
  }) async {
    Query query = _db
        .collection('cases')
        .where('courtLevel', isEqualTo: courtLevel)
        .where('bench', isEqualTo: bench);

    var snapshot = await query.get();
    List<Case> allResults = snapshot.docs
        .map((doc) => Case.fromFirestore(doc))
        .toList();

    if (searchTerm.isEmpty) return allResults;

    // Client-side filtering for search term (Case Number, Plaintiff, or Defendant)
    String lowerSearch = searchTerm.toLowerCase();
    return allResults.where((c) {
      return c.caseNumber.toLowerCase().contains(lowerSearch) ||
          c.plaintiffName.toLowerCase().contains(lowerSearch) ||
          c.defendantName.toLowerCase().contains(lowerSearch);
    }).toList();
  }

  // Submit a complaint
  Future<void> submitComplaint(Complaint complaint) async {
    await _db.collection('general_complaints').add(complaint.toFirestore());
  }
}
