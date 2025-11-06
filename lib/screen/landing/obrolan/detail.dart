import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic>? chatData;
  // TODO: Anda akan butuh public key penerima di sini
  // final String recipientPublicKey;

  const DetailScreen({
    super.key,
    required this.chatId,
    this.chatData,
    // required this.recipientPublicKey,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // TODO: Ganti List dummy ini dengan data dari database lokal
  // List ini dimodifikasi untuk demo semua fitur
  List<Map<String, dynamic>> messages = [
    {
      'id': '1',
      'text': 'Halo, bagaimana kabarmu?',
      'isMe': false,
      'time': '10:20',
      'type': 'text',
      'status': 'ok', // 'ok', 'sending', 'error'
    },
    {
      'id': '2',
      'text': 'Halo juga! Baik-baik saja. Kamu bagaimana?',
      'isMe': true,
      'time': '10:22',
      'type': 'text',
      'status': 'ok',
    },
    {
      'id': '3',
      'text': 'Ini gambar pemandangan, ada pesan di dalamnya.',
      'isMe': false,
      'time': '10:25',
      'type': 'steganografi',
      'status': 'ok',
      // URL gambar pembawa (cover image)
      'imageUrl': 'https://picsum.photos/seed/pemandangan/300/200',
      // Ini HANYA untuk demo. Aslinya, pesan ini diekstrak dari gambar.
      'pesanRahasia': 'Pesan rahasianya adalah: rapat jam 5.',
    },
    {
      'id': '4',
      'text': 'Oke, segera saya kirim',
      'isMe': true,
      'time': '10:30',
      'type': 'text',
      'status': 'ok',
    },
    {
      'id': '5',
      'text': 'laporan_bulanan.pdf', // Nama file
      'isMe': false,
      'time': '10:35',
      'type': 'file',
      'status': 'ok',
      'fileSize': '2.5 MB',
      // Path file terenkripsi di server/lokal
      'filePath': '/remote/laporan_bulanan.cryptoguard',
    },
    {
      'id': '6',
      'text': 'Pesan ini tidak dapat dibaca.',
      'isMe': false,
      'time': '10:36',
      'type': 'corrupt', // Tipe khusus untuk deteksi integritas gagal
      'status': 'error',
    },
  ];

  String getInitials(String nama) {
    List<String> namaParts = nama.split(' ');
    if (namaParts.length >= 2) {
      return '${namaParts[0][0]}${namaParts[1][0]}'.toUpperCase();
    }
    return nama.length >= 2
        ? nama.substring(0, 2).toUpperCase()
        : nama.toUpperCase();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // TODO: LANGKAH ENKRIPSI TEKS (Kriteria 3: Super Enkripsi)
      // 1. Buat Kunci AES acak (Symmetric Key)
      // 2. Enkripsi 'text' pakai AES-GCM (Modern)
      // 3. (Opsional) Enkripsi hasilnya lagi pakai Vigenere (Klasik)
      // 4. Dapatkan Public Key penerima (misal: widget.recipientPublicKey)
      // 5. Enkripsi Kunci AES tadi pakai Public Key RSA penerima
      // 6. Kirim [EncryptedMessage + EncryptedKey] ke API Laravel
      // 7. Setelah API sukses, baru tambahkan ke list 'messages'

      // (Kode demo: langsung tambahkan ke list lokal)
      setState(() {
        messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': text,
          'isMe': true,
          'time': TimeOfDay.now().format(context),
          'type': 'text',
          'status': 'ok', // Anggap langsung sukses
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatName = widget.chatData?['nama'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
                    'Online',
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
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),

          // Message Input
          Container(
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
                    onSubmitted: (_) => _sendMessage(),
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
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // == WIDGET BUILDER UNTUK BUBBLE CHAT ==
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    Widget bubbleContent;

    switch (message['type']) {
      case 'file':
        bubbleContent = _buildFileBubble(message, isMe);
        break;
      case 'steganografi':
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
            message['text'],
            style: TextStyle(
              color: isMe ? Colors.white : const Color(0xFF002C4B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message['time'],
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
      onTap: () {
        // TODO: Implementasi Buka/Download File
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membuka file ${message['text']}')),
        );
      },
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
                  message['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF002C4B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  message['fileSize'],
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Text(
                  message['time'],
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
            child: Image.network(
              message['imageUrl'],
              width: 250,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF002C4B),
                    fontSize: 14,
                  ),
                ),
                Text(
                  message['time'],
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
                    onPressed: () {
                      _ungkapPesanStego(message);
                    },
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
                message['time'],
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

  // == LOGIKA UNTUK FITUR ==

  void _showAttachmentOptions(BuildContext context) {
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
                // Hapus opsi kirim gambar biasa
                // ListTile(
                //   leading: const Icon(Icons.image, color: Color(0xFF095C94)),
                //   title: const Text('Kirim Gambar (Biasa)'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _kirimGambarBiasa();
                //   },
                // ),
              ],
            ),
          ),
    );
  }

  void _kirimBerkas() async {
    try {
      // Request permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission diperlukan untuk mengakses file'),
          ),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        int fileSize = result.files.single.size;

        // TODO: Implementasi enkripsi file di sini

        setState(() {
          messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': fileName,
            'isMe': true,
            'time': TimeOfDay.now().format(context),
            'type': 'file',
            'status': 'ok',
            'fileSize': '${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB',
            'filePath': file.path,
          });
        });
        _scrollToBottom();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File $fileName berhasil dikirim')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _kirimSteganografi() async {
    try {
      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        // Show dialog untuk input pesan rahasia
        String? pesanRahasia = await _showInputPesanRahasia();

        if (pesanRahasia != null && pesanRahasia.isNotEmpty) {
          // TODO: Implementasi steganografi LSB di sini
          // Untuk demo, kita langsung tambahkan ke messages

          setState(() {
            messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'text': 'Gambar dengan pesan tersembunyi',
              'isMe': true,
              'time': TimeOfDay.now().format(context),
              'type': 'steganografi',
              'status': 'ok',
              'imageUrl':
                  image.path, // Dalam implementasi nyata, ini URL dari server
              'pesanRahasia': pesanRahasia,
            });
          });
          _scrollToBottom();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesan steganografi berhasil dikirim'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<String?> _showInputPesanRahasia() async {
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

  void _ungkapPesanStego(Map<String, dynamic> message) {
    // TODO: Implementasi ekstraksi LSB dari gambar
    final pesanRahasia =
        message['pesanRahasia'] ?? 'Tidak ada pesan rahasia (demo)';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pesan Tersembunyi'),
            content: Text(pesanRahasia),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showChatInfo(BuildContext context) {
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
                    Icons.info_outline,
                    color: Color(0xFF095C94),
                  ),
                  title: const Text('Info Kontak'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text('Blokir Kontak'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
