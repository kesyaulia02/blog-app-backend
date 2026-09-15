import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:3001/api/v1/posts';

void main() {
  runApp(const BlogApp());
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE88EA5),
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List posts = [];
  List filteredPosts = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPosts();

    searchController.addListener(() {
      searchPosts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================= GET POSTS =================

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        final data = result['data']['posts'] ?? [];

        setState(() {
          posts = data;
          filteredPosts = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showMessage('Gagal mengambil artikel');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint('GET ERROR: $e');

      showMessage(
        'Tidak dapat terhubung ke server',
      );
    }
  }

  // ================= SEARCH =================

  void searchPosts(String keyword) {
    final search = keyword.toLowerCase();

    setState(() {
      filteredPosts = posts.where((post) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final content = (post['content'] ?? '').toString().toLowerCase();

        return title.contains(search) || content.contains(search);
      }).toList();
    });
  }

  // ================= DELETE =================

  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );

      if (response.statusCode == 200) {
        showMessage('Artikel berhasil dihapus');

        getPosts();
      } else {
        showMessage('Gagal menghapus artikel');
      }
    } catch (e) {
      debugPrint('DELETE ERROR: $e');

      showMessage('Terjadi kesalahan');
    }
  }

  // ================= MESSAGE =================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFD96F8A),
      ),
    );
  }

  // ================= DELETE DIALOG =================

  void showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Artikel?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Artikel yang dihapus tidak akan ditampilkan lagi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD96F8A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                deletePost(id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ================= ARTICLE IMAGE =================

  Widget articleImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF6DCE3),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.article_rounded,
          size: 60,
          color: Color(0xFFD96F8A),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF6DCE3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.image_not_supported_rounded,
              size: 55,
              color: Color(0xFFD96F8A),
            ),
          );
        },
      ),
    );
  }

  // ================= ARTICLE CARD =================

  Widget articleCard(Map post) {
    final int id = post['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            articleImage(
              post['imageUrl'],
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ARTICLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD96F8A),
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const Spacer(),

                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.grey,
                    ),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(
                              post: post,
                            ),
                          ),
                        );

                        getPosts();
                      }

                      if (value == 'delete') {
                        showDeleteDialog(id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                post['title'] ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292329),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                post['content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 17,
                    backgroundColor: Color(0xFFFFD9E2),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Color(0xFFD96F8A),
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Text(
                    'Admin Blog',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            id: id,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Baca Selengkapnya',
                      style: TextStyle(
                        color: Color(0xFFD96F8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD96F8A),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPage(),
            ),
          );

          getPosts();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFD96F8A),
          onRefresh: getPosts,
          child: CustomScrollView(
            slivers: [
              // ================= HEADER =================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD9E2),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Color(0xFFD96F8A),
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BLOG APP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Color(0xFFD96F8A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Cerita & Informasi',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFFD96F8A),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Temukan Artikel',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF292329),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Baca berbagai cerita dan informasi menarik hari ini.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= SEARCH =================

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari artikel...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFD96F8A),
                            ),
                            suffixIcon:
                                searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          searchController.clear();
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                        ),
                                      )
                                    : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          const Text(
                            'Artikel Terbaru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${filteredPosts.length} artikel',
                            style: const TextStyle(
                              color: Color(0xFFD96F8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),

              // ================= LOADING =================

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD96F8A),
                    ),
                  ),
                )

              // ================= EMPTY =================

              else if (filteredPosts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 70,
                          color: Color(0xFFE8B8C4),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Artikel tidak ditemukan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Coba cari dengan kata kunci lain.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // ================= ARTICLES =================

              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return articleCard(
                          filteredPosts[index],
                        );
                      },
                      childCount: filteredPosts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL PAGE
// ============================================================

class DetailPage extends StatefulWidget {
  final int id;

  const DetailPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? post;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPost();
  }

  Future<void> getPost() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/${widget.id}'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          post = result['data']['post'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('DETAIL ERROR: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD96F8A),
              ),
            )
          : post == null
              ? const Center(
                  child: Text(
                    'Artikel tidak ditemukan',
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // IMAGE

                      if (post!['imageUrl'] != null)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(24),
                          child: Image.network(
                            post!['imageUrl'],
                            width: double.infinity,
                            height: 240,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                height: 240,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF6DCE3),
                                  borderRadius:
                                      BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color:
                                        Color(0xFFD96F8A),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      // CATEGORY

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5EC),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ARTICLE',
                          style: TextStyle(
                            color: Color(0xFFD96F8A),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // TITLE

                      Text(
                        post!['title'] ?? 'Tanpa Judul',
                        style: const TextStyle(
                          fontSize: 29,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF292329),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // AUTHOR

                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 21,
                            backgroundColor:
                                Color(0xFFFFD9E2),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFFD96F8A),
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Blog',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Penulis Artikel',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Divider(),

                      const SizedBox(height: 20),

                      // CONTENT

                      Text(
                        post!['content'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ============================================================
// ADD PAGE
// ============================================================

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool isLoading = false;

  Future<void> createPost() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      showMessage('Judul dan isi artikel wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl),
      );

      request.fields['userId'] = '1';
      request.fields['categoryId'] = '1';
      request.fields['title'] =
          titleController.text.trim();
      request.fields['content'] =
          contentController.text.trim();

      final response = await request.send();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Artikel berhasil ditambahkan',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFD96F8A),
            ),
          );

          Navigator.pop(context);
        }
      } else {
        showMessage('Gagal menambahkan artikel');
      }
    } catch (e) {
      debugPrint('CREATE ERROR: $e');

      showMessage('Tidak dapat terhubung ke server');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FA),
        elevation: 0,
        title: const Text(
          'Tambah Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Artikel Baru',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Bagikan cerita dan informasi menarik.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Judul Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul artikel',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  color: Color(0xFFD96F8A),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Isi Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Tulis isi artikel di sini...',
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD96F8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    isLoading ? null : createPost,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Publikasikan Artikel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EDIT PAGE
// ============================================================

class EditPage extends StatefulWidget {
  final Map post;

  const EditPage({
    super.key,
    required this.post,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.post['title'] ?? '',
    );

    contentController = TextEditingController(
      text: widget.post['content'] ?? '',
    );
  }

  Future<void> updatePost() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      showMessage('Judul dan isi artikel wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse(
          '$baseUrl/${widget.post['id']}',
        ),
      );

      request.fields['title'] =
          titleController.text.trim();

      request.fields['content'] =
          contentController.text.trim();

      request.fields['categoryId'] =
          (widget.post['categoryId'] ?? 1).toString();

      final response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Artikel berhasil diperbarui',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFD96F8A),
            ),
          );

          Navigator.pop(context);
        }
      } else {
        showMessage('Gagal memperbarui artikel');
      }
    } catch (e) {
      debugPrint('UPDATE ERROR: $e');

      showMessage('Tidak dapat terhubung ke server');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FA),
        elevation: 0,
        title: const Text(
          'Edit Artikel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Artikel',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Perbarui informasi artikel kamu.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Judul Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  color: Color(0xFFD96F8A),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Isi Artikel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD96F8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    isLoading ? null : updatePost,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}