import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMovieFormScreen extends StatefulWidget {
  final Movie movie;

  const EditMovieFormScreen({super.key, required this.movie});

  @override
  _EditMovieFormScreenState createState() => _EditMovieFormScreenState();
}

class _EditMovieFormScreenState extends State<EditMovieFormScreen> {
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _descController = TextEditingController();
  final _languageController = TextEditingController();
  final _landscapeController = TextEditingController();
  final _portraitController = TextEditingController();
  final _teraboxLinkController = TextEditingController();
  List<TextEditingController> _genreControllers = [TextEditingController()];
  List<Map<String, TextEditingController>> _castControllers = [
    {'cast': TextEditingController(), 'character': TextEditingController()}
  ];
  String? _selectedTeraboxOption;
  bool _showLinkInput = false;
  int _descLines = 1; // Track number of lines in description

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.movie.title;
    _yearController.text = widget.movie.year;
    _descController.text = widget.movie.description;
    _languageController.text = widget.movie.language;
    _landscapeController.text = widget.movie.landscape;
    _portraitController.text = widget.movie.portrait;
    _teraboxLinkController.text = widget.movie.teraboxLink ?? '';
    _selectedTeraboxOption = widget.movie.teraboxLink?.toLowerCase() == 'coming soon' ? 'coming soon' : 'add link';
    _showLinkInput = _selectedTeraboxOption == 'add link';
    _genreControllers = widget.movie.genre.take(3).map((genre) => TextEditingController(text: genre)).toList();
    while (_genreControllers.length < 3) {
      _genreControllers.add(TextEditingController());
    }
    _initializeCastControllers();
    _fetchMovieData();

    // Add listeners to update landscape and portrait fields
    _titleController.addListener(_updateImageFields);
    _yearController.addListener(_updateImageFields);

    // Initialize description lines and add listener
    _updateDescLines();
    _descController.addListener(_updateDescLines);
  }

  // Function to update landscape and portrait fields
  void _updateImageFields() {
    final title = _titleController.text.trim();
    final year = _yearController.text.trim();
    if (title.isNotEmpty && year.isNotEmpty) {
      setState(() {
        _landscapeController.text = '$title $year.jpg';
        _portraitController.text = '$title $year.jpg';
      });
    } else {
      setState(() {
        _landscapeController.text = '';
        _portraitController.text = '';
      });
    }
  }

  // Function to calculate and update description lines
  void _updateDescLines() {
    final text = _descController.text;
    final lineCount = '\n'.allMatches(text).length + 1;
    setState(() {
      _descLines = lineCount.clamp(1, 5); // Limit to 1-5 lines for usability
    });
  }

  Future<void> _initializeCastControllers() async {
    try {
      final actorsSnapshot = await FirebaseFirestore.instance.collection('actors').get();
      final existingActors = actorsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Actor.fromJson(data);
      }).toList();

      setState(() {
        _castControllers = widget.movie.cast.map((cast) {
          final actor = existingActors.firstWhere(
            (a) => a.name == cast,
            orElse: () => Actor(id: '', name: cast, image: '', roles: []),
          );
          final role = actor.roles.firstWhere(
            (r) => r.movieId == widget.movie.id,
            orElse: () => Role(movieId: widget.movie.id, character: ''),
          );
          return {
            'cast': TextEditingController(text: cast),
            'character': TextEditingController(text: role.character),
          };
        }).toList();
        if (_castControllers.isEmpty) {
          _castControllers.add({
            'cast': TextEditingController(),
            'character': TextEditingController(),
          });
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateImageFields);
    _yearController.removeListener(_updateImageFields);
    _descController.removeListener(_updateDescLines);
    _titleController.dispose();
    _yearController.dispose();
    _descController.dispose();
    _languageController.dispose();
    _landscapeController.dispose();
    _portraitController.dispose();
    _teraboxLinkController.dispose();
    for (var controller in _genreControllers) {
      controller.dispose();
    }
    for (var map in _castControllers) {
      map['cast']?.dispose();
      map['character']?.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchMovieData() async {
    if (_titleController.text.isNotEmpty && _yearController.text.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(
            'http://www.omdbapi.com/?t=${Uri.encodeComponent(_titleController.text)}&y=${_yearController.text}&apikey=your_api_key'));
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          setState(() {
            _descController.text = data['Plot'] ?? _descController.text;
            _languageController.text = data['Language'] ?? _languageController.text;
            if (data['Genre'] != null) {
              final genres = data['Genre'].split(', ').take(3).toList();
              for (int i = 0; i < genres.length && i < _genreControllers.length; i++) {
                _genreControllers[i].text = genres[i];
              }
            }
            // Landscape and portrait are now handled by _updateImageFields
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _addGenreField() {
    if (_genreControllers.length < 3) {
      setState(() {
        _genreControllers.add(TextEditingController());
      });
    }
  }

  void _addCastField() {
    setState(() {
      _castControllers.add({
        'cast': TextEditingController(),
        'character': TextEditingController(),
      });
    });
  }

  Future<void> _updateMovie() async {
    try {
      final genres = _genreControllers.map((c) => c.text).where((g) => g.isNotEmpty).toList();
      final cast = _castControllers.map((map) => map['cast']!.text).where((c) => c.isNotEmpty).toList();
      final teraboxLink = _selectedTeraboxOption == 'coming soon' ? 'coming soon' : _teraboxLinkController.text;

      // Update movie
      await FirebaseFirestore.instance.collection('movies').doc(widget.movie.id).set({
        'title': _titleController.text,
        'year': _yearController.text,
        'description': _descController.text,
        'language': _languageController.text,
        'genre': genres,
        'landscape': _landscapeController.text,
        'portrait': _portraitController.text,
        'teraboxLink': teraboxLink,
        'cast': cast,
      }, SetOptions(merge: true));

      // Update actors
      final actorsSnapshot = await FirebaseFirestore.instance.collection('actors').get();
      final existingActors = actorsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Actor.fromJson(data);
      }).toList();

      for (var i = 0; i < _castControllers.length; i++) {
        final castName = _castControllers[i]['cast']!.text;
        final character = _castControllers[i]['character']!.text;
        if (castName.isEmpty) continue;

        final actor = existingActors.firstWhere(
          (a) => a.name == castName,
          orElse: () => Actor(id: '', name: castName, image: '', roles: []),
        );
        final roles = actor.id.isNotEmpty
            ? actor.roles.map((r) {
                if (r.movieId == widget.movie.id) {
                  return Role(movieId: r.movieId, character: character.isNotEmpty ? character : castName);
                }
                return r;
              }).toList()
            : [];
        if (!roles.any((r) => r.movieId == widget.movie.id)) {
          roles.add(Role(movieId: widget.movie.id, character: character.isNotEmpty ? character : castName));
        }

        if (actor.id.isEmpty) {
          // Create new actor
          final newActorRef = await FirebaseFirestore.instance.collection('actors').add({
            'actor_name': castName,
            'actor_image': '',
            'roles': roles.map((r) => {'movie_id': r.movieId, 'character': r.character}).toList(),
            'id': '',
          });
          await newActorRef.update({'id': newActorRef.id});
        } else {
          // Update existing actor
          await FirebaseFirestore.instance.collection('actors').doc(actor.id).update({
            'actor_name': actor.name,
            'actor_image': actor.image,
            'roles': roles.map((r) => {'movie_id': r.movieId, 'character': r.character}).toList(),
          });
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating movie: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Movie'),
        backgroundColor: const Color(0xFF00203F),
      ),
      backgroundColor: const Color(0xFF0A1A2F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: _descLines,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _languageController,
              decoration: const InputDecoration(
                labelText: 'Language',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ..._genreControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Genre ${index + 1}',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0D3B66)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (index == _genreControllers.length - 1 && _genreControllers.length < 3)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addGenreField,
                      ),
                  ],
                ),
              );
            }).toList(),
            TextField(
              controller: _landscapeController,
              decoration: const InputDecoration(
                labelText: 'Landscape',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portraitController,
              decoration: const InputDecoration(
                labelText: 'Portrait',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              enabled: false,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTeraboxOption,
              decoration: const InputDecoration(
                labelText: 'Terabox Link',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D3B66)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color(0xFF0D3B66),
              items: ['coming soon', 'add link'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeraboxOption = value;
                  _showLinkInput = value == 'add link';
                });
              },
            ),
            if (_showLinkInput) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _teraboxLinkController,
                decoration: const InputDecoration(
                  labelText: 'Add Link',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0D3B66)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
            const SizedBox(height: 16),
            ..._castControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controllers = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controllers['cast'],
                        decoration: InputDecoration(
                          labelText: 'Cast ${index + 1}',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0D3B66)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controllers['character'],
                        decoration: InputDecoration(
                          labelText: 'Character ${index + 1}',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0D3B66)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (index == _castControllers.length - 1)
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addCastField,
                      ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateMovie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B66),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update',
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
    );
  }
}