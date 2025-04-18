import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glass_kit/glass_kit.dart';
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
  String selectedMenuItem = 'Home';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/movies.json');
      final List<dynamic> data = jsonDecode(response);
      setState(() {
        movies = data.map((json) => Movie.fromJson(json)).toList();
        filteredMovies = movies;
      });
    } catch (e) {
      print('Error loading movies: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Pagination logic can be added here
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        drawer: Drawer(
          child: GlassContainer(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.8,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderColor: Colors.white.withOpacity(0.2),
            blur: 20,
            child: Column(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A2A44), Color(0xFF3B82F6)],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_filter,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'MovieHub',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      _buildMenuItem(
                        icon: Icons.home,
                        title: 'Home',
                        isSelected: selectedMenuItem == 'Home',
                        onTap: () {
                          setState(() => selectedMenuItem = 'Home');
                          Navigator.pop(context);
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.person,
                        title: 'Profile',
                        isSelected: selectedMenuItem == 'Profile',
                        onTap: () {
                          setState(() => selectedMenuItem = 'Profile');
                          Navigator.pop(context);
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: 'Settings',
                        isSelected: selectedMenuItem == 'Settings',
                        onTap: () {
                          setState(() => selectedMenuItem = 'Settings');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                      borderColor: Colors.red.withOpacity(0.3),
                      blur: 10,
                      borderRadius: BorderRadius.circular(12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
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
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'MovieHub',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/backgrounds/featured.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F172A).withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF1A2A44),
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
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Language Filters
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  // Search Bar
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSearchVisible
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: GlassContainer(
                              height: 50,
                              width: double.infinity,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderColor: Colors.white.withOpacity(0.3),
                              blur: 10,
                              borderRadius: BorderRadius.circular(25),
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
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20,
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
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onChanged: _filterMovies,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Movie Grid
            movies.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : filteredMovies.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No movies found',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2 / 3.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              try {
                                final movie = filteredMovies[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MovieDetailsScreen(movie: movie),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: FadeInUp(
                                    duration: const Duration(milliseconds: 300),
                                    child: GlassContainer(
                                      height: 230,
                                      width: MediaQuery.of(context).size.width / 3 - 24,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.05),
                                        ],
                                      ),
                                      borderColor: Colors.white.withOpacity(0.2),
                                      blur: 10,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                child: Image.asset(
                                                  'assets/portrait/${movie.portrait}',
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 180,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    print('Image load error: $error');
                                                    return Container(
                                                      height: 180,
                                                      color: Colors.grey,
                                                      child: const Icon(Icons.error, color: Colors.white),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GlassContainer(
                                                  height: 20,
                                                  width: 60,
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red.withOpacity(0.3),
                                                      Colors.red.withOpacity(0.2),
                                                    ],
                                                  ),
                                                  borderColor: Colors.red.withOpacity(0.3),
                                                  blur: 5,
                                                  borderRadius: BorderRadius.circular(5),
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  movie.title,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
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
                                  ),
                                );
                              } catch (e) {
                                print('Error rendering movie at index $index: $e');
                                return Container(
                                  color: Colors.red.withOpacity(0.2),
                                  child: const Center(child: Text('Error')),
                                );
                              }
                            },
                            childCount: filteredMovies.length,
                          ),
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
      child: InkWell(
        onTap: () => _filterByLanguage(language),
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          height: 36,
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]
                : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
          ),
          borderColor: Colors.white.withOpacity(0.3),
          blur: 10,
          borderRadius: BorderRadius.circular(20),
          child: Text(
            language,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        gradient: LinearGradient(
          colors: isSelected
              ? [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]
              : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        ),
        borderColor: Colors.white.withOpacity(0.3),
        blur: 10,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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