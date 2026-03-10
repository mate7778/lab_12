import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import 'stat_bar.dart';

/// แสดง Base Stats ของ Pokémon พร้อม staggered animation
/// แต่ละ stat bar จะเริ่ม animate ไม่พร้อมกัน (ด้วย Interval)
class PokemonStats extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonStats({super.key, required this.pokemon});

  @override
  State<PokemonStats> createState() => _PokemonStatsState();
}

class _PokemonStatsState extends State<PokemonStats>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // เริ่ม animation หลัง build เสร็จ
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// สร้าง animation ที่เริ่มช้าลง (stagger) ตาม index
  Animation<double> _createStaggeredAnimation(int index) {
    final start = index * 0.1;
    final end = start + 0.6;
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'HP', 'value': widget.pokemon.hp, 'color': Colors.red},
      {
        'label': 'Attack',
        'value': widget.pokemon.attack,
        'color': Colors.orange,
      },
      {
        'label': 'Defense',
        'value': widget.pokemon.defense,
        'color': Colors.blue,
      },
      {
        'label': 'Sp. Atk',
        'value': widget.pokemon.specialAttack,
        'color': Colors.purple,
      },
      {
        'label': 'Sp. Def',
        'value': widget.pokemon.specialDefense,
        'color': Colors.green,
      },
      {'label': 'Speed', 'value': widget.pokemon.speed, 'color': Colors.pink},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Base Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...stats.asMap().entries.map((entry) {
              return StatBar(
                label: entry.value['label'] as String,
                value: entry.value['value'] as int,
                color: entry.value['color'] as Color,
                animation: _createStaggeredAnimation(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }
}
