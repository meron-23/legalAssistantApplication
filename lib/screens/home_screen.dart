import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';
import '../services/database_service.dart';
import '../services/seeder_service.dart';
import 'chat_bot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAccess(context),
          const SizedBox(height: 16),
          // Temporary Seed Button
          Center(
            child: TextButton.icon(
              onPressed: () async {
                try {
                  await SeederService().seedData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database seeded successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error seeding: $e')));
                }
              },
              icon: const Icon(Icons.data_saver_on),
              label: const Text('Seed Sample Data'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Latest Announcements',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Announcement>>(
            stream: dbService.getAnnouncements(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading announcements'));
              }
              final announcements = snapshot.data ?? [];
              if (announcements.isEmpty) {
                return const Center(
                  child: Text('No announcements at this time.'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      announcement.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(announcement.content),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(announcement.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.blue[800],
          child: InkWell(
            onTap: () {
              // Navigation is handled by BottomNavigationBar in MainScaffold
              // But we can add a prompt or just let the user know where to go.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Use the "Track Case" tab below.'),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track a Case',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Search by number or parties',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.smart_toy, color: Colors.blueGrey),
            title: const Text('Legal Assistant Bot'),
            subtitle: const Text('Get answers to general court procedures'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
