import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers untuk form editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // States
  bool _isEditing = false;
  File? _avatarImage;

  // Dummy data - nanti diganti dengan data real dari storage/database
  String userName = "Budi Santoso";
  String username = "@budisantoso123";
  String email = "budi.santoso@email.com";
  String bio = "Seorang developer yang peduli keamanan data";
  String joinDate = "Bergabung sejak Januari 2024";

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = userName;
    _usernameController.text = username.replaceFirst('@', '');
    _emailController.text = email;
    _bioController.text = bio;
  }

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
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: const Color(0xFF095C94),
            ),
            onPressed: _isEditing ? _saveProfile : _toggleEditing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(),

            const SizedBox(height: 24),

            // Profile Information Card
            _buildProfileInformation(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Section
          GestureDetector(
            onTap: _isEditing ? () => _showAvatarOptions(context) : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF095C94),
                  backgroundImage:
                      _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child:
                      _avatarImage == null
                          ? Text(
                            getInitials(userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          )
                          : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDB634),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF002C4B),
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Name and Username
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002C4B),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            username,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          const SizedBox(height: 8),

          Text(
            joinDate,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002C4B),
            ),
          ),

          const SizedBox(height: 20),

          // Nama Lengkap
          _buildProfileField(
            label: 'Nama Lengkap',
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),

          const SizedBox(height: 16),

          // Username
          _buildProfileField(
            label: 'Username',
            controller: _usernameController,
            icon: Icons.alternate_email,
            enabled: _isEditing,
            prefix: '@',
          ),

          const SizedBox(height: 16),

          // Email
          _buildProfileField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Bio
          _buildProfileField(
            label: 'Bio',
            controller: _bioController,
            icon: Icons.info_outline,
            enabled: _isEditing,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? const Color(0xFF002C4B) : Colors.grey[600],
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? const Color(0xFF095C94) : Colors.grey[400],
            ),
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF095C94)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if cancelled
        _initializeControllers();
      }
    });
  }

  void _saveProfile() {
    // TODO: Implementasi save profile ke database/API
    setState(() {
      userName = _nameController.text;
      username = '@${_usernameController.text}';
      email = _emailController.text;
      bio = _bioController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: Color(0xFF095C94),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002C4B),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatarOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                    _buildAvatarOption(
                      context,
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                    if (_avatarImage != null)
                      _buildAvatarOption(
                        context,
                        icon: Icons.delete,
                        label: 'Hapus',
                        onTap: () {
                          Navigator.pop(context);
                          _removeAvatar();
                        },
                        isDelete: true,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDelete
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF095C94).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDelete ? Colors.red[700] : const Color(0xFF095C94),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDelete ? Colors.red[700] : const Color(0xFF002C4B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showPermissionDialog('Kamera');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      var storageStatus = await Permission.photos.request();
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          _showPermissionDialog('Galeri');
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarImage = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Foto profil dihapus')));
  }

  void _showPermissionDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Permission Diperlukan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            content: Text(
              'Aplikasi memerlukan akses $feature untuk mengubah foto profil.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF095C94),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
