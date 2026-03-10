import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/pokeball_spinner.dart';
import '../routes/pokemon_route.dart';
import 'pokemon_detail_screen.dart';

/// หน้าหลักแสดงรายการ Pokémon
/// Animation ที่ใช้:
/// - Shimmer Loading (ขณะโหลดข้อมูล)
/// - Staggered Grid Entry (card ปรากฏทีละใบ)
/// - AnimatedSwitcher (สลับ Grid/List view)
/// - Hero (ไปหน้า Detail)
/// - Custom Page Transition (PokemonPageRoute)
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen>
    with TickerProviderStateMixin {
  List<Pokemon> _pokemons = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String? _errorMessage;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final pokemons = await PokemonService.fetchPokemonList(limit: 20);
      if (!mounted) return;
      setState(() {
        _pokemons = pokemons;
        _isLoading = false;
      });
      _staggerController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดข้อมูลได้\n$e';
      });
    }
  }

  void _navigateToDetail(Pokemon pokemon) {
    Navigator.push(
      context,
      PokemonPageRoute(
        page: PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.catching_pokemon, size: 28),
            SizedBox(width: 8),
            Text('Pokédex', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          // Toggle Grid/List ด้วย AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: IconButton(
              key: ValueKey(_isGridView),
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoading();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PokeballSpinner(size: 60),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPokemons,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    // AnimatedSwitcher สลับระหว่าง Grid กับ List
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child:
          _isGridView
              ? _buildGrid(key: const ValueKey('grid'))
              : _buildList(key: const ValueKey('list')),
    );
  }

  Widget _buildGrid({Key? key}) {
    return GridView.builder(
      key: key,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _pokemons.length,
      itemBuilder: (context, index) {
        // Staggered animation: แต่ละ card เริ่ม animate ช้าลงตาม index
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              (index / _pokemons.length * 0.6).clamp(0.0, 1.0),
              ((index / _pokemons.length * 0.6) + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        return PokemonCard(
          pokemon: _pokemons[index],
          animation: animation,
          onTap: () => _navigateToDetail(_pokemons[index]),
        );
      },
    );
  }

  Widget _buildList({Key? key}) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.all(16),
      itemCount: _pokemons.length,
      itemBuilder: (context, index) {
        final pokemon = _pokemons[index];
        return _HoverablePokemonTile(
          key: ValueKey(pokemon.id),
          pokemon: pokemon,
          onTap: () => _navigateToDetail(pokemon),
        );
      },
    );
  }
}

class _HoverablePokemonTile extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const _HoverablePokemonTile({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  State<_HoverablePokemonTile> createState() => _HoverablePokemonTileState();
}

class _HoverablePokemonTileState extends State<_HoverablePokemonTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hovering ? 1.02 : 1.0;
    final color = _hovering ? Colors.grey.shade100 : Colors.white;
    final elevation = _hovering ? 8.0 : 2.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,
        child: Card(
          color: color,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: widget.onTap,
            leading: Hero(
              tag: 'pokemon-${widget.pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                width: 50,
                height: 50,
                placeholder: (_, __) => const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.catching_pokemon, size: 40),
              ),
            ),
            title: Text(
              widget.pokemon.name[0].toUpperCase() +
                  widget.pokemon.name.substring(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                Text('#${widget.pokemon.id.toString().padLeft(3, '0')}'),
            trailing: Wrap(
              spacing: 4,
              children: widget.pokemon.types.map((type) {
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
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
