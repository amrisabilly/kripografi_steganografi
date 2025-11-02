import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002C4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002C4B),
            letterSpacing: 1,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Halaman Profil\n(Akan diimplementasikan)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF002C4B)),
        ),
      ),
    );
  }
}
