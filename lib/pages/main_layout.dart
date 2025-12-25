import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/home_page.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // This list holds the widgets for each tab
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text("Builds Page")), // Placeholder
    const Center(child: Text("Chat Page")),   // Placeholder
    const Center(child: Text("Profile Page")), // Placeholder
  ];

  // This list holds the titles for the AppBar
  final List<String> _titles = [
    "PCBuddy",
    "My Builds",
    "Tech Support",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        // You can add logic here later to show different actions per page
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
        type: BottomNavigationBarType.fixed, // Necessary for 4+ items
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Builds"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}