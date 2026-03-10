import 'package:flutter/material.dart';
import 'screens/pokemon_list_screen.dart';

void main() => runApp(const PokedexApp());

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: const PokemonListScreen(),
    );
  }
}
