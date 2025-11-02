import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ObrolanScreen extends StatefulWidget {
  const ObrolanScreen({super.key});

  @override
  State<ObrolanScreen> createState() => _ObrolanScreenState();
}

class _ObrolanScreenState extends State<ObrolanScreen> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredObrolan = [];

  // Dummy data untuk demo - nanti diganti dengan data dari database
  final List<Map<String, dynamic>> obrolanList = [
    {
      'id': '1',
      'nama': 'Budi Santoso',
      'pesanTerakhir': 'Anda: Oke, segera saya kirim',
      'waktu': '10:30',
      'tipepesan': 'teks',
      'belumDibaca': true,
    },
    {
      'id': '2',
      'nama': 'Sari Wulandari',
      'pesanTerakhir': '🖼️ Pesan dalam Gambar',
      'waktu': 'Kemarin',
      'tipepesan': 'steganografi',
      'belumDibaca': false,
    },
    {
      'id': '3',
      'nama': 'Ahmad Rahman',
      'pesanTerakhir': '📁 Berkas: laporan.pdf',
      'waktu': '2 hari lalu',
      'tipepesan': 'file',
      'belumDibaca': false,
    },
    {
      'id': '4',
      'nama': 'Lisa Dewi',
      'pesanTerakhir': '⚠️ Pesan tidak dapat dibaca',
      'waktu': '3 hari lalu',
      'tipepesan': 'korup',
      'belumDibaca': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    filteredObrolan = obrolanList;
  }

  void _filterObrolan(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredObrolan = obrolanList;
      } else {
        filteredObrolan =
            obrolanList
                .where(
                  (obrolan) => obrolan['nama'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredObrolan = obrolanList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        title:
            isSearching
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  style: const TextStyle(
                    color: Color(0xFF002C4B),
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari obrolan...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterObrolan,
                )
                : const Text(
                  'CryptoGuard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002C4B),
                    letterSpacing: 1,
                  ),
                ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF095C94),
              size: 26,
            ),
          ),
        ],
      ),
      body:
          filteredObrolan.isEmpty && !isSearching
              ? _buildEmptyState()
              : filteredObrolan.isEmpty && isSearching
              ? _buildNoSearchResults()
              : _buildChatList(filteredObrolan),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to search user screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigasi ke halaman cari pengguna')),
          );
        },
        backgroundColor: const Color(0xFFFDB634),
        foregroundColor: const Color(0xFF002C4B),
        elevation: 3,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Mulai Percakapan Aman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Tekan tombol '+' di kanan bawah untuk mencari kontak dan memulai obrolan terenkripsi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil pencarian',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> obrolanList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: obrolanList.length,
      itemBuilder: (context, index) {
        final obrolan = obrolanList[index];
        return _buildChatItem(obrolan);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> obrolan) {
    String getInitials(String nama) {
      List<String> namaParts = nama.split(' ');
      if (namaParts.length >= 2) {
        return '${namaParts[0][0]}${namaParts[1][0]}'.toUpperCase();
      }
      return nama.length >= 2
          ? nama.substring(0, 2).toUpperCase()
          : nama.toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          context.push('/chat-detail/${obrolan['id']}', extra: obrolan);
        },
        onLongPress: () {
          _showChatOptions(context, obrolan);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF095C94),
                child: Text(
                  getInitials(obrolan['nama']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content (Nama dan Pesan)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obrolan['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002C4B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      obrolan['pesanTerakhir'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Waktu dan Indikator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    obrolan['waktu'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  if (obrolan['belumDibaca'])
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDB634),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context, Map<String, dynamic> obrolan) {
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
                    Icons.archive_outlined,
                    color: Color(0xFF095C94),
                  ),
                  title: const Text('Arsipkan Obrolan'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${obrolan['nama']} diarsipkan')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Obrolan'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${obrolan['nama']} dihapus')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
