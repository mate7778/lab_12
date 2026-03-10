import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';

/// Card แสดง Pokémon พร้อม staggered animation
/// รับ Animation<double> จาก parent เพื่อควบคุม slide-in + fade-in
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Animation<double> animation;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final primaryColor = Pokemon.typeColor(pokemon.types.first);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            // Background Pokéball watermark
            Positioned(
              bottom: -15,
              right: -15,
              child: Icon(
                Icons.catching_pokemon,
                size: 80,
                color: primaryColor.withOpacity(0.08),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID + Name row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${pokemon.id.toString().padLeft(3, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              pokemon.name[0].toUpperCase() +
                                  pokemon.name.substring(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Small badge row
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: pokemon.types.map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Pokemon.typeColor(type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  // Fill remainder with the Pokemon image
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.catching_pokemon, size: 60),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
