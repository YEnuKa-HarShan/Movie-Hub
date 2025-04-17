import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';
import 'actor_details_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  List<Actor> actors = [];
  List<CastDisplay> castDisplay = [];

  @override
  void initState() {
    super.initState();
    _loadActors();
  }

  Future<void> _loadActors() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/actors/actors.json');
      final List<dynamic> data = jsonDecode(response);
      setState(() {
        actors = data.map((json) => Actor.fromJson(json)).toList();
        _prepareCastDisplay();
      });
    } catch (e) {
      print('Error loading actors: $e');
    }
  }

  void _prepareCastDisplay() {
    castDisplay = actors
        .where((actor) => widget.movie.cast.contains(actor.name))
        .map((actor) {
      final role = actor.roles.firstWhere(
        (r) => r.movieId == widget.movie.id,
        orElse: () => Role(movieId: widget.movie.id, character: 'Unknown'),
      );
      return CastDisplay(
        actorName: actor.name,
        characterName: role.character,
        image: actor.image,
      );
    }).toList();
  }

  void _handleDownload(BuildContext context) async {
    if (widget.movie.teraboxLink == null || widget.movie.teraboxLink!.toLowerCase() == "coming soon") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A1A2F),
          title: const Text(
            'Coming Soon',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'This movie will be available soon!',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF00A8E8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final Uri url = Uri.parse(widget.movie.teraboxLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not launch the link',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
              ),
              backgroundColor: Color(0xFF00203F),
            ),
          );
        }
      }
    }
  }

  List<TextSpan> _parseDescription(String description) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(description)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: description.substring(lastIndex, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF00A8E8),
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < description.length) {
      spans.add(TextSpan(
        text: description.substring(lastIndex),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
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
                widget.movie.title,
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
                    'assets/landscape/${widget.movie.landscape}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.movie.language,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        widget.movie.year,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Genre: ${widget.movie.genre.join(", ")}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      children: widget.movie.description.isEmpty
                          ? [
                              const TextSpan(
                                text: 'Description coming soon',
                              ),
                            ]
                          : _parseDescription(widget.movie.description),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: actors.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: castDisplay.map((cast) {
                                final actor = actors.firstWhere(
                                  (a) => a.name == cast.actorName,
                                  orElse: () => Actor(
                                    id: 'unknown',
                                    name: cast.actorName,
                                    image: cast.image,
                                    roles: [],
                                  ),
                                );
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActorDetailsScreen(actor: actor),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: AssetImage('assets/actors/${cast.image}'),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          cast.actorName,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          cast.characterName,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleDownload(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Download',
                        style: TextStyle(
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
          ),
        ],
      ),
    );
  }
}