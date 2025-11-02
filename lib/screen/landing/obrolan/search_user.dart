import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Dummy data pengguna terdaftar - nanti diganti dengan API call
  final List<Map<String, dynamic>> _allUsers = [
    {
      'id': '5',
      'nama': 'Rina Kartika',
      'username': '@rina_kartika',
      'email': 'rina.kartika@email.com',
      'status': 'Online',
      'isOnline': true,
    },
    {
      'id': '6',
      'nama': 'Doni Prasetyo',
      'username': '@doni_prasetyo',
      'email': 'doni.prasetyo@email.com',
      'status': 'Terakhir dilihat 5 menit lalu',
      'isOnline': false,
    },
    {
      'id': '7',
      'nama': 'Maya Sari',
      'username': '@maya_sari',
      'email': 'maya.sari@email.com',
      'status': 'Online',
      'isOnline': true,
    },
    {
      'id': '8',
      'nama': 'Rahmat Hidayat',
      'username': '@rahmat_hidayat',
      'email': 'rahmat.hidayat@email.com',
      'status': 'Terakhir dilihat 1 jam lalu',
      'isOnline': false,
    },
    {
      'id': '9',
      'nama': 'Fitri Anggraini',
      'username': '@fitri_anggraini',
      'email': 'fitri.anggraini@email.com',
      'status': 'Online',
      'isOnline': true,
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

  void _searchUsers(String query) {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    // Simulasi delay API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _searchResults = [];
          } else {
            _searchResults =
                _allUsers.where((user) {
                  return user['nama'].toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      user['username'].toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      user['email'].toLowerCase().contains(query.toLowerCase());
                }).toList();
          }
          _isSearching = false;
        });
      }
    });
  }

  void _startChat(Map<String, dynamic> user) {
    // TODO: Implementasi logika untuk memulai chat baru
    // 1. Cek apakah chat dengan user ini sudah ada
    // 2. Jika belum ada, buat chat baru di database
    // 3. Navigate ke detail chat

    // Untuk demo, langsung navigate ke chat detail
    context.push(
      '/chat-detail/${user['id']}',
      extra: {
        'id': user['id'],
        'nama': user['nama'],
        'username': user['username'],
        'status': user['status'],
        'isNewChat': true,
      },
    );
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
          'Cari Pengguna',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002C4B),
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Color(0xFF002C4B), fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Cari nama, username, atau email...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF095C94)),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _searchUsers('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResultsState();
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    return _buildInitialState();
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Cari Pengguna CryptoGuard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002C4B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Masukkan nama, username, atau email untuk mencari pengguna yang terdaftar di CryptoGuard.',
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF095C94)),
          ),
          const SizedBox(height: 16),
          Text(
            'Mencari pengguna...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Pengguna tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF002C4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba gunakan kata kunci lain atau pastikan pengguna sudah terdaftar di CryptoGuard.',
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

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF095C94),
              child: Text(
                getInitials(user['nama']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (user['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user['nama'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF002C4B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['username'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              user['status'],
              style: TextStyle(
                fontSize: 12,
                color: user['isOnline'] ? Colors.green : Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDB634),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Chat',
            style: TextStyle(
              color: Color(0xFF002C4B),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () => _startChat(user),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
