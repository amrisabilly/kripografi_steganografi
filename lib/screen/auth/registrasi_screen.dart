import 'dart:convert';
import 'package:aplikasi_dua/services/api_service.dart';
import 'package:aplikasi_dua/services/crypto_service.dart';
import 'package:aplikasi_dua/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrasiScreen extends StatefulWidget {
  const RegistrasiScreen({super.key});

  @override
  State<RegistrasiScreen> createState() => _RegistrasiScreenState();
}

class _RegistrasiScreenState extends State<RegistrasiScreen> {
  bool isPasswordVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController(); // <-- TAMBAHAN
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _apiService = ApiService();
  final _cryptoService = CryptoService();
  final _storageService = StorageService();

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // 1. Generate Kunci RSA
        final keys = await _cryptoService.generateRsaKeyPair();
        final publicKey = keys['publicKey']!;
        final privateKey = keys['privateKey']!;

        // 2. Kirim data ke API
        final response = await _apiService.register(
          username: _usernameController.text,
          displayName: _namaController.text,
          email: _emailController.text,
          password: _passwordController.text,
          publicKey: publicKey,
        );

        if (response.statusCode == 201) {
          // 3. JIKA SUKSES, simpan Private Key
          await _storageService.savePrivateKey(privateKey);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registrasi berhasil! Silakan login.'),
                backgroundColor: Colors.green),
          );
          if (mounted) context.go('/login');
        } else {
          final body = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Registrasi gagal: ${body['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Image(
                    image: AssetImage("assets/images/logo_apl.png"),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
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
                          controller: _namaController,
                          validator: (val) =>
                              val!.isEmpty ? 'Nama tidak boleh kosong' : null,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration(
                              'Nama Lengkap', Icons.person_outline),
                        ),
                        const SizedBox(height: 20),

                        // Username Field (TAMBAHAN)
                        TextFormField(
                          controller: _usernameController,
                          validator: (val) => val!.isEmpty
                              ? 'Username tidak boleh kosong'
                              : null,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration(
                              'Username (cth: budi123)', Icons.alternate_email),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          validator: (val) =>
                              val!.isEmpty ? 'Email tidak boleh kosong' : null,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration(
                              'Email', Icons.email_outlined),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        StatefulBuilder(
                          builder: (context, setState) {
                            return TextFormField(
                              controller: _passwordController,
                              validator: (val) => val!.length < 6
                                  ? 'Password minimal 6 karakter'
                                  : null,
                              obscureText: !isPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration:
                                  _buildInputDecoration('Password', Icons.lock_outline)
                                      .copyWith(
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
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDB634),
                              foregroundColor: const Color(0xFF002C4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF002C4B),
                                  )
                                : const Text(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Color(0xFFFDCF7B), fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFFDCF7B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFFDB634)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFFFDCF7B).withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFDB634), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }
}