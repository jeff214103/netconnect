import 'package:flutter/material.dart';
import 'package:netconnect/provider/data_provider.dart';
import 'package:netconnect/ui/events_screen.dart';
import 'package:netconnect/ui/people_screen.dart';
import 'package:netconnect/ui/settings_screen.dart';
import 'package:netconnect/ui/ai_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final isAuthenticated = provider.isAuthenticated;

    print(
      'HomePage build: isAuthenticated=$isAuthenticated, isLoading=${provider.isLoading}',
    );

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('NetConnect')),
        body: const Center(child: SettingsScreen()),
      );
    }

    final screens = [
      const EventsScreen(),
      const PeopleScreen(),
      const AIScreen(),
      const SettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout
          return Scaffold(
            body: screens[provider.selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: provider.selectedIndex,
              onDestinationSelected: (index) =>
                  provider.setSelectedIndex(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today),
                  label: 'Events',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people),
                  label: 'People',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome),
                  label: 'Ask AI',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        } else {
          // Desktop layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: provider.selectedIndex,
                  onDestinationSelected: (index) =>
                      provider.setSelectedIndex(index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_rounded),
                      label: Text('Events'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_rounded),
                      label: Text('People'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_rounded),
                      label: Text('Ask AI'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_rounded),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: screens[provider.selectedIndex]),
              ],
            ),
          );
        }
      },
    );
  }
}
