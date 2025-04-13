import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // For blur effect
import '../models/movie.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  bool isSearchVisible = false;
  String selectedLanguage = '';
  String? userRole;
  String selectedMenuItem = 'Home'; // Track selected menu item
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'User';
      print('User role loaded: $userRole');
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Pagination can be added here
    }
  }

  void _filterMovies(String query) {
    setState(() {
      filteredMovies = movies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()) &&
              (selectedLanguage.isEmpty || movie.language == selectedLanguage))
          .toList();
    });
  }

  void _filterByLanguage(String language) {
    setState(() {
      selectedLanguage = (selectedLanguage == language) ? '' : language;
      _filterMovies(_searchController.text);
    });
  }

  Future<bool> _onWillPop() async {
    if (selectedLanguage.isNotEmpty) {
      setState(() {
        selectedLanguage = '';
        _filterMovies(_searchController.text);
      });
      return false;
    }
    return true;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login', // Route name defined in main.dart
        (Route<dynamic> route) => false, // Removes all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1A2F),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 4,
          title: const Text(
            'MovieHub',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() => isSearchVisible = !isSearchVisible);
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Stack(
            children: [
              // Glass blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: const Color(0xFF0A1A2F).withOpacity(0.5), // Match home background
                ),
              ),
              // Drawer content
              Column(
                children: [
                  // Drawer Header
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.movie_filter,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover Movies',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      children: [
                        _buildMenuItem(
                          icon: Icons.home,
                          title: 'Home',
                          isSelected: selectedMenuItem == 'Home',
                          onTap: () {
                            setState(() {
                              selectedMenuItem = 'Home';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.person,
                          title: 'Profile',
                          isSelected: selectedMenuItem == 'Profile',
                          onTap: () {
                            setState(() {
                              selectedMenuItem = 'Profile';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          isSelected: selectedMenuItem == 'Settings',
                          onTap: () {
                            setState(() {
                              selectedMenuItem = 'Settings';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: _logout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Color(0xFFFF4D4D), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF4D4D),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black.withOpacity(0.3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildLanguageButton('English'),
                    _buildLanguageButton('Tamil'),
                    _buildLanguageButton('Hindi'),
                    _buildLanguageButton('Malayalam'),
                    _buildLanguageButton('Telugu'),
                    _buildLanguageButton('Kannada'),
                    _buildLanguageButton('French'),
                    _buildLanguageButton('Korean'),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isSearchVisible
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search movies...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 24,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterMovies('');
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: _filterMovies,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('movies').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('Firestore error: ${snapshot.error}');
                    if (snapshot.error.toString().contains('permission-denied')) {
                      return const Center(
                        child: Text(
                          'Permission denied: Unable to load movies. Check your user role or contact support.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        'Error loading movies: ${snapshot.error}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies found',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  movies = snapshot.data!.docs
                      .map((doc) => Movie.fromJson(doc.data() as Map<String, dynamic>))
                      .toList();
                  filteredMovies = movies
                      .where((movie) =>
                          movie.title
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()) &&
                          (selectedLanguage.isEmpty ||
                              movie.language == selectedLanguage))
                      .toList();
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2 / 3.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [Colors.blueGrey.shade900, Colors.black87],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: Image.asset(
                                        'assets/portrait/${movie.portrait}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.5),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          movie.language,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 32,
                                      child: Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      movie.year,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String language) {
    bool isSelected = selectedLanguage == language;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _filterByLanguage(language),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00A8E8) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 6)]
                : null,
          ),
          child: Text(
            language,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF00203F), const Color(0xFF0D3B66)]
                : [
                    Colors.blueGrey.shade900.withOpacity(0.2),
                    Colors.black87.withOpacity(0.2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.blueAccent.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00A8E8) : Colors.white.withOpacity(0.9),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isSelected ? const Color(0xFF00A8E8) : Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}