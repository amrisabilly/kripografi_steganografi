import 'package:aplikasi_dua/screen/landing/obrolan/index.dart';
import 'package:aplikasi_dua/screen/landing/pengaturan/index.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ObrolanScreen(),
    const PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF095C94), Color(0xFF002C4B)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFDB634),
          unselectedItemColor: const Color(0xFFFDCF7B).withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded, size: 24),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 26),
              label: 'Obrolan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 24),
              activeIcon: Icon(Icons.settings_outlined, size: 26),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
