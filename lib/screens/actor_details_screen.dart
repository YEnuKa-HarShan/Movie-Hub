import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';

class ActorDetailsScreen extends StatefulWidget {
  final Actor actor;

  const ActorDetailsScreen({super.key, required this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/movies/movies.json');
      final List<dynamic> data = jsonDecode(response);
      setState(() {
        movies = data.map((json) => Movie.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = movies.where((movie) => movie.cast.contains(widget.actor.name)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.actor.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/actors/${widget.actor.image}',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A1A2F).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF00203F),
            elevation: 4,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Movies',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  filteredMovies.isEmpty
                      ? Text(
                          'No movies found for ${widget.actor.name}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/portrait/${movie.portrait}',
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  movie.year,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsScreen(movie: movie),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}