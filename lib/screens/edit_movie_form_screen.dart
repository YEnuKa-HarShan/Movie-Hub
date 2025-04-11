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
  List<TextEditingController> _castControllers = [TextEditingController()];
  String? _selectedTeraboxOption;
  bool _showLinkInput = false;

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
    _castControllers = widget.movie.cast.map((cast) => TextEditingController(text: cast)).toList();
    if (_castControllers.isEmpty) {
      _castControllers.add(TextEditingController());
    }
    _fetchMovieData();
  }

  @override
  void dispose() {
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
    for (var controller in _castControllers) {
      controller.dispose();
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
            _landscapeController.text = '${_titleController.text} ${_yearController.text}.jpg';
            _portraitController.text = '${_titleController.text} ${_yearController.text}.jpg';
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
      _castControllers.add(TextEditingController());
    });
  }

  Future<void> _updateMovie() async {
    try {
      final genres = _genreControllers.map((c) => c.text).where((g) => g.isNotEmpty).toList();
      final cast = _castControllers.map((c) => c.text).where((c) => c.isNotEmpty).toList();
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

      for (var castName in cast) {
        final actor = existingActors.firstWhere(
          (a) => a.name == castName,
          orElse: () => Actor(id: '', name: castName, image: '', roles: []),
        );
        final roles = actor.id.isNotEmpty
            ? actor.roles.map((r) {
                if (r.movieId == widget.movie.id) {
                  return Role(movieId: r.movieId, character: castName);
                }
                return r;
              }).toList()
            : [];
        if (!roles.any((r) => r.movieId == widget.movie.id)) {
          roles.add(Role(movieId: widget.movie.id, character: castName));
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
              onChanged: (value) => _fetchMovieData(),
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
              onChanged: (value) => _fetchMovieData(),
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
              maxLines: 3,
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
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
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