import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 15);

  /// ดึงรายการ Pokémon พร้อมรายละเอียด
  static Future<List<Pokemon>> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      // ดึงรายละเอียดของแต่ละตัว (parallel)
      final futures = results.map((r) async {
        try {
          final detailResponse = await http
              .get(Uri.parse(r['url']))
              .timeout(_timeout);
          if (detailResponse.statusCode == 200) {
            return Pokemon.fromJson(jsonDecode(detailResponse.body));
          }
        } catch (_) {
          // Skip failed individual requests
        }
        return null;
      });

      final pokemons = await Future.wait(futures);
      return pokemons.whereType<Pokemon>().toList();
    }
    throw Exception('Failed to load Pokémon list: ${response.statusCode}');
  }

  /// ดึงข้อมูล Pokémon ตัวเดียวจาก id
  static Future<Pokemon> fetchPokemon(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/pokemon/$id'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load Pokémon #$id');
  }
}
