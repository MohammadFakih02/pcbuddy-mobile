import 'package:flutter/material.dart';
import 'package:pcbuddy/pages/build_page.dart';
import 'package:pcbuddy/pages/home_page.dart';
import 'package:pcbuddy/pages/laptop_input_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 1. Define the 4 pages
  final List<Widget> _pages = [
    const HomePage(),
    const PCBuilderPage(),
    const LaptopInputPage(),
    const Center(child: Text("Profile Page")),
  ];

  final List<String> _titles = [
    "PCBuddy",
    "Custom Build",
    "Laptop Analyzer",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
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
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.computer), label: "Builds"),
          BottomNavigationBarItem(icon: Icon(Icons.laptop_mac), label: "Laptops"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}