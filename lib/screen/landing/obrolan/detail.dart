import 'dart:convert';
import 'dart:typed_data';
import 'package:aplikasi_dua/services/api_service.dart';
import 'package:aplikasi_dua/services/crypto_service.dart';
import 'package:aplikasi_dua/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DetailScreen extends StatefulWidget {
  final String chatId; // Ini adalah ID Pengguna Penerima
  final Map<String, dynamic>? chatData;
  final String recipientPublicKey; // <-- PENTING: Wajib ada

  const DetailScreen({
    super.key,
    required this.chatId,
    this.chatData,
    required this.recipientPublicKey, // <-- PENTING: Wajib ada
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // Servis
  final ApiService _apiService = ApiService();
  final CryptoService _cryptoService = CryptoService();
  final StorageService _storageService = StorageService();

  // State
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = true;
  String? _myPrivateKey;

  @override
  void initState() {
    super.initState();
    _loadAllMessages();
  }

  Future<void> _loadAllMessages() async {
    setState(() => _isLoadingMessages = true);
    try {
      _myPrivateKey = await _storageService.getPrivateKey();
      if (_myPrivateKey == null) {
        throw Exception('Private key tidak ditemukan. Harap login ulang.');
      }

      final userId = await _storageService.getUserId();
      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Harap login ulang.');
      }
      final response = await _apiService.getMessages(userId: int.parse(userId));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          for (var msg in body) {
            // 'isMe' ditentukan oleh backend
            final isMe = msg['sender_id'] == userId;
            final contentType = msg['content_type'];
            final payload = msg['encrypted_payload'];

            String decryptedText = '';
            Uint8List? decryptedData;
            String type = contentType;

            if (isMe) {
              // Jika pesan kita, kita tidak dekripsi (kita sudah tahu isinya)
              // Di aplikasi nyata, kita juga harus mengenkripsi untuk diri sendiri
              // Tapi untuk sekarang, kita ambil dari data dummy jika ada
              decryptedText =
                  msg['file_name'] ??
                  (contentType == 'steganography'
                      ? 'Gambar Stego Terkirim'
                      : 'Teks Terkirim');
            } else {
              // Jika pesan orang lain, DEKRIPSI
              print('[DEBUG] Akan mendekripsi payload: $payload');
              print('[DEBUG] Private key: $_myPrivateKey');
              decryptedData = _cryptoService.decryptHybrid(
                payload,
                _myPrivateKey!,
              );

              if (decryptedData == null) {
                // GAGAL DEKRIPSI = KORUP (Kriteria 6)
                type = 'corrupt';
              } else if (contentType == 'text') {
                // Dekripsi Vigenere (lapisan kedua)
                String decryptedAes = utf8.decode(decryptedData);
                decryptedText = _cryptoService.vigenereDecrypt(
                  decryptedAes,
                  "kunciRahasia",
                );
              } else if (contentType == 'file') {
                decryptedText = msg['file_name'] ?? 'File Diterima';
                // decryptedData disimpan untuk dibuka nanti
              } else if (contentType == 'steganography') {
                decryptedText = 'Gambar Diterima (ada pesan rahasia)';
                // decryptedData disimpan untuk diekstrak nanti
              }
            }

            _messages.add({
              'id': msg['id'].toString(),
              'text': decryptedText,
              'isMe': isMe,
              'time': msg['created_at'], // Ambil dari API
              'type': type,
              'status': 'ok',
              'file_name': msg['file_name'],
              'file_size': msg['file_size'],
              'decryptedData': decryptedData, // Simpan data biner
              'payload': payload, // Simpan payload asli (untuk stego)
            });
          }
        }

        setState(() {
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      } else {
        throw Exception('Gagal memuat pesan: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoadingMessages = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- MENGIRIM PESAN (SEMUA JENIS) ---
  Future<void> _sendMessage({
    required String contentType,
    required Uint8List dataToEncrypt, // Data mentah (teks/file)
    String? fileName,
    String? fileSize,
  }) async {
    try {
      // 1. Enkripsi (Hybrid AES + RSA)
      final payload = _cryptoService.encryptHybrid(
        dataToEncrypt,
        widget.recipientPublicKey,
      );

      // 2. Kirim ke API
      final senderId = await _storageService.getUserId();
      if (senderId == null) {
        throw Exception('User ID tidak ditemukan. Harap login ulang.');
      }

      final response = await _apiService.sendMessage(
        senderId: senderId,
        recipientId: widget.chatId,
        contentType: contentType,
        encryptedPayload: payload,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (response.statusCode == 201) {
        // 3. Jika sukses, muat ulang pesan
        _loadAllMessages();
      } else {
        throw Exception('Gagal mengirim pesan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- Handler Tombol Kirim (Teks) ---
  void _handleSendText() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // Kriteria 3: Super Enkripsi (Vigenere + AES)
      final vigenereEncrypted = _cryptoService.vigenereEncrypt(
        text,
        "kunciRahasia",
      );
      final data = utf8.encode(vigenereEncrypted);

      _sendMessage(contentType: 'text', dataToEncrypt: data);
      _messageController.clear();
    }
  }

  // --- Handler Tombol Kirim (File) ---
  void _kirimBerkas() async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) return;

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        Uint8List fileBytes = await file.readAsBytes();

        // Kriteria 5: Enkripsi File
        _sendMessage(
          contentType: 'file',
          dataToEncrypt: fileBytes,
          fileName: result.files.single.name,
          fileSize:
              '${(result.files.single.size / 1024 / 1024).toStringAsFixed(1)} MB',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // --- Handler Tombol Kirim (Stego) ---
  void _kirimSteganografi() async {
    try {
      // 1. Pilih Gambar Pembawa
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      // 2. Input Pesan Rahasia
      String? pesanRahasia = await _showInputPesanRahasia();
      if (pesanRahasia == null || pesanRahasia.isEmpty) return;

      // 3. Lakukan LSB Embed (Kriteria 4)
      final Uint8List imageBytes = await image.readAsBytes();
      final Uint8List? stegoBytes = _cryptoService.lsbEmbed(
        imageBytes,
        pesanRahasia,
      );

      if (stegoBytes == null) {
        throw Exception('Gagal membuat gambar steganografi.');
      }

      // 4. Kirim sebagai 'file' (tapi tipenya steganografi)
      _sendMessage(
        contentType: 'steganography',
        dataToEncrypt: stegoBytes, // Ini adalah gambar yg sudah disisipi
        fileName: 'stego_image.png',
        fileSize:
            '${(stegoBytes.lengthInBytes / 1024 / 1024).toStringAsFixed(1)} MB',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // --- Handler Bubble Chat ---

  void _handleFileTap(Map<String, dynamic> message) {
    final Uint8List? data = message['decryptedData'];
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk dibuka (demo)')),
      );
      return;
    }
    // TODO: Simpan 'data' (Uint8List) ke file sementara dan buka pakai open_file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka file ${message['file_name']}')),
    );
  }

  void _ungkapPesanStego(Map<String, dynamic> message) {
    Uint8List? stegoData;

    if (message['isMe']) {
      // Jika pesan kita, payload-nya belum di-dekripsi
      // Ini skenario rumit, demo ini akan fokus pada pesan diterima
    } else {
      // Jika pesan diterima, data binernya ada di 'decryptedData'
      stegoData = message['decryptedData'];
    }

    if (stegoData == null) {
      // Coba ambil dari payload (ini mungkin data terenkripsi)
      // Logika demo:
      final demoPesan = message['pesanRahasia']; // Ambil dari data dummy
      if (demoPesan != null) {
        _showPesanTerungkap(demoPesan);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data gambar (demo)')),
      );
      return;
    }

    // Ekstrak LSB
    final String? pesanRahasia = _cryptoService.lsbExtract(stegoData);
    _showPesanTerungkap(pesanRahasia);
  }

  void _showPesanTerungkap(String? pesan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pesan Tersembunyi'),
            content: Text(
              pesan ?? 'Gagal mengekstrak pesan atau tidak ada pesan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // --- UI Widgets (Sebagian besar tidak berubah) ---

  @override
  Widget build(BuildContext context) {
    final chatName = widget.chatData?['display_name'] ?? 'Unknown';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        // ... (Kode AppBar Anda sudah bagus)
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002C4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF095C94),
              child: Text(
                getInitials(chatName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF002C4B),
                    ),
                  ),
                  const Text(
                    'Online', // TODO: Ganti dengan status asli
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF095C94)),
            onPressed: () {
              _showChatInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
          ),
          Container(
            // ... (Kode Input Area Anda sudah bagus)
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF095C94)),
                  onPressed: () {
                    _showAttachmentOptions(context);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF095C94)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _handleSendText(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDB634),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF002C4B)),
                    onPressed: _handleSendText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    // ... (Kode _buildMessageBubble Anda dari file sebelumnya)
    // Modifikasi: ganti 'message['text']' dengan 'message['text'] ?? '...'
    // ... dan panggil _handleFileTap dan _ungkapPesanStego

    final isMe = message['isMe'] as bool;
    Widget bubbleContent;
    switch (message['type']) {
      case 'file':
        bubbleContent = _buildFileBubble(message, isMe);
        break;
      case 'steganography':
        bubbleContent = _buildStegoBubble(message, isMe);
        break;
      case 'corrupt':
        bubbleContent = _buildCorruptBubble(message, isMe);
        break;
      case 'text':
      default:
        bubbleContent = _buildTextBubble(message, isMe);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) const SizedBox(width: 50),
          Flexible(child: bubbleContent),
          if (isMe) const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildTextBubble(Map<String, dynamic> message, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF095C94) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['text'] ?? '...',
            style: TextStyle(
              color: isMe ? Colors.white : const Color(0xFF002C4B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message['time'] ?? '..:..',
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileBubble(Map<String, dynamic> message, bool isMe) {
    return InkWell(
      onTap: () => _handleFileTap(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF095C94) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isMe ? Colors.white : const Color(0xFF095C94),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['file_name'] ?? 'File',
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF002C4B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message['file_size'] ?? '...',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Text(
                  message['time'] ?? '..:..',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStegoBubble(Map<String, dynamic> message, bool isMe) {
    // Demo: Jika 'decryptedData' ada, tampilkan sebagai gambar
    // Di aplikasi nyata, Anda akan mengunduh dari URL
    final Uint8List? imageData = message['decryptedData'];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF095C94) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                (imageData != null)
                    ? Image.memory(
                      imageData,
                      width: 250,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      // Placeholder jika tidak ada gambar
                      width: 250,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe
                      ? (message['file_name'] ?? 'Gambar Terkirim')
                      : 'Gambar diterima',
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF002C4B),
                    fontSize: 14,
                  ),
                ),
                Text(
                  message['time'] ?? '..:..',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
                if (!isMe) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB634),
                      foregroundColor: const Color(0xFF002C4B),
                    ),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ungkap Pesan'),
                    onPressed: () => _ungkapPesanStego(message),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorruptBubble(Map<String, dynamic> message, bool isMe) {
    // ... (Kode _buildCorruptBubble Anda sudah bagus)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF095C94) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesan Gagal Dimuat',
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF002C4B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Data mungkin rusak atau diubah.',
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Text(
                message['time'] ?? '..:..',
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  String getInitials(String nama) =>
      (nama.isNotEmpty)
          ? nama
              .trim()
              .split(' ')
              .map((l) => l.isNotEmpty ? l[0] : '')
              .take(2)
              .join()
              .toUpperCase()
          : '';
  void _scrollToBottom() {
    /* ... */
  }
  void _showAttachmentOptions(BuildContext context) {
    // ... (Kode _showAttachmentOptions Anda sudah bagus)
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: Color(0xFF095C94),
                  ),
                  title: const Text('Kirim Berkas (File)'),
                  onTap: () {
                    Navigator.pop(context);
                    _kirimBerkas();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.hide_image,
                    color: Color(0xFFFDB634),
                  ),
                  title: const Text('Sisipkan Pesan (Steganografi)'),
                  onTap: () {
                    Navigator.pop(context);
                    _kirimSteganografi();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<String?> _showInputPesanRahasia() async {
    // ... (Kode _showInputPesanRahasia Anda sudah bagus)
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pesan Rahasia'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Masukkan pesan yang akan disembunyikan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showChatInfo(BuildContext context) {
    /* ... (Kode _showChatInfo Anda sudah bagus) */
  }
}
