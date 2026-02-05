import 'package:cloud_firestore/cloud_firestore.dart';

class SeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedData() async {
    final batch = _db.batch();

    // 1. Seed Benches
    final benches = [
      // Federal Supreme Court
      {'courtLevel': 'Federal Supreme Court', 'benchName': 'Main Bench'},

      // Federal High Court
      {'courtLevel': 'Federal High Court', 'benchName': 'Lideta Crime'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Lideta Civil'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Arada'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Bole'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Kaliti'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Diredawa'},
      {'courtLevel': 'Federal High Court', 'benchName': 'Hawassa'},

      // First Instance Court
      {'courtLevel': 'First Instance Court', 'benchName': 'Addis Ketema'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Kolfe Keraniy'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Yeka'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Lideta'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Akaki Kality'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Bole'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Nigid'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Lemikura'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Arada'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Lafto'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Menagesha'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Kirkos'},
      {'courtLevel': 'First Instance Court', 'benchName': 'Diredawa'},
    ];

    for (var bench in benches) {
      final docRef = _db.collection('benches').doc();
      batch.set(docRef, bench);
    }

    // 2. Seed Announcements
    final announcements = [
      {
        'title': 'Court Holiday Notice',
        'content':
            'The federal courts will be closed on January 7th for the holiday.',
        'date': Timestamp.now(),
      },
      {
        'title': 'New Filing Procedure',
        'content':
            'Digital filing is now mandatory for all civil cases in the High Court.',
        'date': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        ),
      },
      {
        'title': 'Legal Aid Clinic',
        'content':
            'Free legal aid clinic will be held this Friday at the Lideta Bench.',
        'date': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now()
              .subtract(const Duration(days: 5))
              .millisecondsSinceEpoch,
        ),
      },
    ];

    for (var ann in announcements) {
      final docRef = _db.collection('announcements').doc();
      batch.set(docRef, ann);
    }

    // 3. Seed Cases
    final cases = [
      {
        'caseNumber': 'FSC/1023/24',
        'plaintiffName': 'Abebe Kebede',
        'defendantName': 'Ministry of Finance',
        'courtLevel': 'Federal Supreme Court',
        'bench': 'Main Bench',
        'status': 'Under Review',
        'nextHearingDate': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().add(const Duration(days: 14)).millisecondsSinceEpoch,
        ),
        'caseDetails':
            'Appeal against the lower court decision on tax calculation.',
      },
      {
        'caseNumber': 'FHC/505/23',
        'plaintiffName': 'Ethio Telecom',
        'defendantName': 'Global Trading Ltd',
        'courtLevel': 'Federal High Court',
        'bench': 'Lideta Civil',
        'status': 'Ongoing',
        'nextHearingDate': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
        ),
        'caseDetails': 'Breach of contract regarding infrastructure supply.',
      },
      {
        'caseNumber': 'FIC/991/24',
        'plaintiffName': 'Sara Mohammed',
        'defendantName': 'Dawit Tadesse',
        'courtLevel': 'First Instance Court',
        'bench': 'Lideta',
        'status': 'Awaiting Evidence',
        'nextHearingDate': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().add(const Duration(days: 21)).millisecondsSinceEpoch,
        ),
        'caseDetails':
            'Property dispute regarding inheritance of family estate.',
      },
      {
        'caseNumber': 'FHC/202/24',
        'plaintiffName': 'Daniel Tekle',
        'defendantName': 'Zemen Bank',
        'courtLevel': 'Federal High Court',
        'bench': 'Lideta Civil',
        'status': 'Judgment Pending',
        'nextHearingDate': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch,
        ),
        'caseDetails': 'Employment dispute regarding termination benefits.',
      },
      {
        'caseNumber': 'FIC/115/24',
        'plaintiffName': 'Martha Girma',
        'defendantName': 'City Administration',
        'courtLevel': 'First Instance Court',
        'bench': 'Arada',
        'status': 'Scheduled',
        'nextHearingDate': Timestamp.fromMillisecondsSinceEpoch(
          DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch,
        ),
        'caseDetails': 'Land use permit challenge.',
      },
    ];

    for (var caseItem in cases) {
      final docRef = _db.collection('cases').doc();
      batch.set(docRef, caseItem);
    }

    await batch.commit();
  }
}
