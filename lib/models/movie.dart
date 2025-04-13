class Movie {
  final String id;
  final String title;
  final String description;
  final String year;
  final String language;
  final List<String> genre;
  final String portrait;
  final String landscape;
  final String? teraboxLink;
  final List<String> cast;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.language,
    required this.genre,
    required this.portrait,
    required this.landscape,
    this.teraboxLink,
    required this.cast,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? 'unknown_id',
      title: json['title'] ?? json['Title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No description available',
      year: json['year'] ?? json['Year'] ?? 'Unknown Year',
      language: json['language'] ?? json['Language'] ?? 'Unknown Language',
      genre: List<String>.from(json['genre'] ?? json['Genre'] ?? []),
      portrait: json['portrait'] ?? json['Portrait'] ?? 'default_portrait.jpg',
      landscape: json['landscape'] ?? json['Landscape'] ?? 'default_landscape.jpg',
      teraboxLink: json['terabox_link'] ?? json['teraboxLink'],
      cast: List<String>.from(json['cast'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'year': year,
      'language': language,
      'genre': genre,
      'portrait': portrait,
      'landscape': landscape,
      'terabox_link': teraboxLink,
      'cast': cast,
    };
  }
}

class Actor {
  final String id;
  final String name;
  final String image;
  final List<Role> roles;

  Actor({
    required this.id,
    required this.name,
    required this.image,
    required this.roles,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id']?.toString() ?? 'unknown_id',
      name: json['actor_name'] ?? json['name'] ?? 'Unknown Actor',
      image: json['actor_image'] ?? json['image'] ?? 'default_actor.jpg',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((r) => Role.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_name': name,
      'actor_image': image,
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class Role {
  final String movieId;
  final String character;

  Role({required this.movieId, required this.character});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      movieId: json['movie_id']?.toString() ?? 'unknown_movie',
      character: json['character'] ?? 'Unknown Character',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': movieId,
      'character': character,
    };
  }
}

class CastDisplay {
  final String actorName;
  final String characterName;
  final String image;

  CastDisplay({
    required this.actorName,
    required this.characterName,
    required this.image,
  });
}