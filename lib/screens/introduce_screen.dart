import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glass_kit/glass_kit.dart';
import 'login_screen.dart';

class IntroduceScreen extends StatefulWidget {
  const IntroduceScreen({super.key});

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Discover Movies',
      'description': 'Explore a vast collection of movies across genres and languages.',
      'icon': Icons.movie_filter,
      'background': 'assets/backgrounds/discover.jpg',
    },
    {
      'title': 'Personalized Experience',
      'description': 'Filter by language and search for your favorite films effortlessly.',
      'icon': Icons.search,
      'background': 'assets/backgrounds/search.jpg',
    },
    {
      'title': 'Join the Community',
      'description': 'Log in to unlock downloads and exclusive features.',
      'icon': Icons.group,
      'background': 'assets/backgrounds/community.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Image.asset(
                    _steps[index]['background'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: GlassContainer(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 400,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderColor: Colors.white.withOpacity(0.3),
                        blur: 10,
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _steps[index]['icon'],
                              color: Colors.white,
                              size: 80,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _steps[index]['title'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                _steps[index]['description'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _steps.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      GlassContainer(
                        height: 50,
                        width: 120,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderColor: Colors.white.withOpacity(0.3),
                        blur: 10,
                        borderRadius: BorderRadius.circular(25),
                        child: TextButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == _steps.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}