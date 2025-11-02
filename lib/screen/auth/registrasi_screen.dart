import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrasiScreen extends StatelessWidget {
  const RegistrasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPasswordVisible = false;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002C4B), Color(0xFF095C94)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo
                const Image(
                  image: AssetImage("assets/images/logo_apl.png"),
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                // App name
                ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [Color(0xFFFDCF7B), Color(0xFFFDB634)],
                      ).createShader(bounds),
                  child: const Text(
                    'CryptoGuard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFDCF7B),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 40),

                // Registration Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFDCF7B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Nama Lengkap Field
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: const TextStyle(
                            color: Color(0xFFFDCF7B),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFFDB634),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFFDCF7B).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFDB634),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Color(0xFFFDCF7B),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFFFDB634),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFFDCF7B).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFFDB634),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      StatefulBuilder(
                        builder: (context, setState) {
                          return TextFormField(
                            obscureText: !isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                color: Color(0xFFFDCF7B),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFFDB634),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFFDB634),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(
                                    0xFFFDCF7B,
                                  ).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFDB634),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add registration logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDB634),
                            foregroundColor: const Color(0xFF002C4B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: Color(0xFFFDCF7B), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to login screen
                        context.go('/login');
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Color(0xFFFDB634),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFFDB634),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
