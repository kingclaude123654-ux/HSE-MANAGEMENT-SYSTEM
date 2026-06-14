import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'incident_form_screen.dart';
import 'action_tracker_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IncidentReportProApp());
}

class IncidentReportProApp extends StatelessWidget {
  const IncidentReportProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Report Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3A60),
          primary: const Color(0xFF1F3A60),
          secondary: const Color(0xFFE65100),
        ),
      ),
      home: const MainNavigationContainer(),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const IncidentFormScreen(),
    const ActionTrackerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.add_moderator_rounded), label: 'Log Incident'),
          NavigationDestination(icon: Icon(Icons.assignment_turned_in_rounded), label: 'Actions'),
        ],
      ),
    );
  }
}
