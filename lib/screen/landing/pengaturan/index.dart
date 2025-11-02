import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  // Dummy data - nanti diganti dengan data real dari storage/database
  final String userName = "Budi Santoso";
  final String username = "@budisantoso123";
  final String publicKey = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1234567890abcdef...
-----END PUBLIC KEY-----""";
  final String appVersion = "1.0.0";

  String getInitials(String nama) {
    List<String> namaParts = nama.split(' ');
    if (namaParts.length >= 2) {
      return '${namaParts[0][0]}${namaParts[1][0]}'.toUpperCase();
    }
    return nama.length >= 2
        ? nama.substring(0, 2).toUpperCase()
        : nama.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002C4B),
            letterSpacing: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Grup 1: Profil Akun
          _buildProfileTile(context),

          const SizedBox(height: 32),

          // Grup 2: Keamanan
          _buildSectionHeader('KEAMANAN'),
          const SizedBox(height: 8),
          _buildSecuritySection(context),

          const SizedBox(height: 32),

          // Grup 3: Bantuan
          _buildSectionHeader('BANTUAN'),
          const SizedBox(height: 8),
          _buildHelpSection(context),

          const SizedBox(height: 32),

          // Grup 4: Akun (Logout)
          _buildAccountSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF095C94),
          child: Text(
            getInitials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF002C4B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            username,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF095C94)),
        onTap: () {
          // TODO: Navigate to profile screen
          context.push('/profile');
        },
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDB634).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.vpn_key_outlined,
            color: Color(0xFFFDB634),
            size: 24,
          ),
        ),
        title: const Text(
          'Kunci Publik Saya',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF002C4B),
          ),
        ),
        subtitle: const Text(
          'Bagikan untuk verifikasi',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF095C94)),
        onTap: () {
          _showPublicKeyDialog(context);
        },
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF095C94).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF095C94),
                size: 24,
              ),
            ),
            title: const Text(
              'Tentang CryptoGuard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF002C4B),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF095C94)),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF095C94).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: Color(0xFF095C94),
                size: 24,
              ),
            ),
            title: const Text(
              'Kebijakan Privasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF002C4B),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF095C94)),
            onTap: () {
              _launchPrivacyPolicy();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.logout, color: Colors.red[700], size: 24),
        ),
        title: Text(
          'Keluar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red[700],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.red[700]),
        onTap: () {
          _showLogoutDialog(context);
        },
      ),
    );
  }

  void _showPublicKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Kunci Publik Saya',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bagikan kunci publik ini untuk verifikasi identitas:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    publicKey,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDB634),
                  foregroundColor: const Color(0xFF002C4B),
                ),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Salin Kunci'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: publicKey));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kunci publik disalin')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Tentang CryptoGuard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CryptoGuard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF095C94),
                  ),
                ),
                Text(
                  'Versi $appVersion',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aplikasi komunikasi terenkripsi end-to-end yang menjamin keamanan dan privasi pesan Anda.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fitur utama:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Enkripsi AES-GCM + RSA\n'
                  '• Steganografi LSB\n'
                  '• Transfer file terenkripsi\n'
                  '• Deteksi integritas pesan',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF095C94),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _launchPrivacyPolicy() async {
    const url =
        'https://cryptoguard.example.com/privacy'; // Ganti dengan URL Anda
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // Jika gagal buka URL, tampilkan dialog
      // showDialog dengan konten kebijakan privasi
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Konfirmasi Keluar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            content: const Text(
              'Anda yakin ingin keluar dari akun ini?',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _performLogout(context);
                },
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  void _performLogout(BuildContext context) {
    // TODO: Implementasi logout
    // 1. Hapus token dari flutter_secure_storage
    // 2. Hapus kunci privat dari secure storage
    // 3. Clear semua data lokal
    // 4. Navigate ke login screen

    // Simulasi logout
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Berhasil keluar')));

    // Navigate to login and clear stack
    context.go('/login');
  }
}
