import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/build_page.dart';
import 'package:pcbuddy/pages/home_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Updated List: Removed Chat
  final List<Widget> _pages = [
    const HomePage(),
    const PCBuilderPage(),
    const Center(child: Text("Profile Page")), // Placeholder for Profile
  ];

  // Updated Titles
  final List<String> _titles = [
    "PCBuddy",
    "My Builds",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        // Show "Add" button only on Builds page
        actions: _currentIndex == 1 
          ? [IconButton(onPressed: () {}, icon: const Icon(Icons.add))] 
          : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false, // Cleaner look
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.computer), label: "Builds"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}