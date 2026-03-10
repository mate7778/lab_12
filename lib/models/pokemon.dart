import 'package:flutter/material.dart';

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final double height;
  final double weight;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.height,
    required this.weight,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as List;
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ??
              json['sprites']['front_default'] ??
              '',
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      hp: stats[0]['base_stat'],
      attack: stats[1]['base_stat'],
      defense: stats[2]['base_stat'],
      specialAttack: stats[3]['base_stat'],
      specialDefense: stats[4]['base_stat'],
      speed: stats[5]['base_stat'],
      height: json['height'] / 10.0,
      weight: json['weight'] / 10.0,
    );
  }

  /// สี type ของ Pokémon
  static Color typeColor(String type) {
    switch (type) {
      case 'fire':
        return const Color(0xFFEE8130);
      case 'water':
        return const Color(0xFF6390F0);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'psychic':
        return const Color(0xFFF95587);
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'rock':
        return const Color(0xFFB6A136);
      case 'ghost':
        return const Color(0xFF735797);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'dark':
        return const Color(0xFF705746);
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'fairy':
        return const Color(0xFFD685AD);
      case 'normal':
      default:
        return const Color(0xFFA8A77A);
    }
  }
}
