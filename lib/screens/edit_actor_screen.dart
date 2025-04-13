import 'package:flutter/material.dart';
import '../models/movie.dart';

class EditActorScreen extends StatefulWidget {
  final Actor actor;

  const EditActorScreen({super.key, required this.actor});

  @override
  State<EditActorScreen> createState() => _EditActorScreenState();
}

class _EditActorScreenState extends State<EditActorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.actor.name);
    _imageController = TextEditingController(text: widget.actor.image);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveActor() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Firestore update logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Actor details saved!',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
          backgroundColor: Color(0xFF00203F),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      appBar: AppBar(
        title: const Text(
          'Edit Actor',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00203F),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actor Details',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: false, // Disable editing
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Actor Name',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0D3B66),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF00A8E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the actor\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageController,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Image File Name',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0D3B66),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF00A8E8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the image file name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveActor,
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
                      'Save',
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
      ),
    );
  }
}