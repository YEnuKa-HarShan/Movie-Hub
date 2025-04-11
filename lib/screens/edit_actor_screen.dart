import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class EditActorScreen extends StatefulWidget {
  final String movieId;
  final List<Actor> actors;

  const EditActorScreen({super.key, required this.movieId, required this.actors});

  @override
  _EditActorScreenState createState() => _EditActorScreenState();
}

class _EditActorScreenState extends State<EditActorScreen> {
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _imageControllers;
  late List<TextEditingController> _characterControllers;

  @override
  void initState() {
    super.initState();
    _nameControllers = widget.actors
        .map((actor) => TextEditingController(text: actor.name))
        .toList();
    _imageControllers = widget.actors
        .map((actor) => TextEditingController(text: actor.image))
        .toList();
    _characterControllers = widget.actors
        .map((actor) => TextEditingController(
            text: actor.roles
                .firstWhere((r) => r.movieId == widget.movieId)
                .character))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _imageControllers) {
      controller.dispose();
    }
    for (var controller in _characterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _updateActors() async {
    try {
      for (int i = 0; i < widget.actors.length; i++) {
        final actor = widget.actors[i];
        final updatedRoles = actor.roles.map((role) {
          if (role.movieId == widget.movieId) {
            return Role(
              movieId: role.movieId,
              character: _characterControllers[i].text,
            );
          }
          return role;
        }).toList();

        await FirebaseFirestore.instance
            .collection('actors')
            .doc(actor.id)
            .update({
          'actor_name': _nameControllers[i].text,
          'actor_image': _imageControllers[i].text,
          'roles': updatedRoles
              .map((r) => {'movie_id': r.movieId, 'character': r.character})
              .toList(),
        });
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actors updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating actors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Actors'),
        backgroundColor: const Color(0xFF00203F),
      ),
      backgroundColor: const Color(0xFF0A1A2F),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.actors.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF0D3B66),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Actor Name',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _imageControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Image Path',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _characterControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Character Name',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateActors,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update Actors',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}