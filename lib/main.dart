import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/case_tracking_screen.dart';
import 'screens/complaint_screen.dart';
import 'screens/chat_bot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    print('Options for current platform: ${options.projectId}');
    await Firebase.initializeApp(options: options);
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(const LegalAssistantApp());
}

class LegalAssistantApp extends StatelessWidget {
  const LegalAssistantApp({super.key});

  static const Color primaryNavy = Color(0xFF0D47A1);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Federal Court Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentGold,
          surface: Colors.white,
          onSurface: Colors.blueGrey[900],
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueGrey[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryNavy, width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CaseTrackingScreen(),
    const ComplaintScreen(),
  ];

  final List<String> _titles = [
    'Federal Court News',
    'Track Your Case',
    'Submit Complaint',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/logo.png', height: 32),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              activeIcon: Icon(Icons.newspaper, color: Color(0xFF0D47A1)),
              label: 'Announcements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, color: Color(0xFF0D47A1)),
              label: 'Track Case',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review),
              activeIcon: Icon(Icons.rate_review, color: Color(0xFF0D47A1)),
              label: 'Complaints',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.blueGrey[300],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBotScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Legal Assistant Bot',
        child: const Icon(Icons.smart_toy, size: 28),
      ),
    );
  }
}
