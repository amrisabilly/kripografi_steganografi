import 'package:aplikasi_dua/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aplikasi Coffe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.soraTextTheme()),
      routerConfig: router,
    );
  }
}
