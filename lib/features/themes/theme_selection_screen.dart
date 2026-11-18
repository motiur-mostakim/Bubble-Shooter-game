import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/models/player_data.dart';
import '../../data/models/theme_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/static_data/themes_data.dart';

class ThemeSelectionScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const ThemeSelectionScreen({super.key, required this.playerRepository});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  PlayerData _player = const PlayerData();

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final player = await widget.playerRepository.loadPlayer();
    setState(() => _player = player);
  }

  Future<void> _selectTheme(String themeId) async {
    final updated = _player.copyWith(selectedTheme: themeId);
    await widget.playerRepository.savePlayer(updated);
    _loadPlayer();
  }

  Future<void> _unlockTheme(ThemeModel theme) async {
    if (_player.coins >= theme.unlockCostCoins) {
      final unlocked = List<String>.from(_player.unlockedThemes)..add(theme.id);
      final updated = _player.copyWith(
        coins: _player.coins - theme.unlockCostCoins,
        unlockedThemes: unlocked,
        selectedTheme: theme.id,
      );
      await widget.playerRepository.savePlayer(updated);
      _loadPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mainBackgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('ENVIRONMENT GALLERY', style: AppTextStyles.title(fontSize: 22)),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: ThemesData.themes.length,
                  itemBuilder: (context, index) {
                    final theme = ThemesData.themes[index];
                    final isUnlocked = _player.unlockedThemes.contains(theme.id) || theme.isDefault;
                    final isSelected = _player.selectedTheme == theme.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomCard(
                        borderColor: isSelected
                            ? Colors.amberAccent
                            : isUnlocked
                                ? theme.primaryColor
                                : Colors.grey.shade700,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Rich Illustrated Environment Thumbnail Preview
                            Container(
                              width: 80,
                              height: 80,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.amberAccent : theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    theme.skyAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: theme.backgroundColor,
                                    ),
                                  ),
                                  Image.asset(
                                    theme.distantAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: 24,
                                    child: Image.asset(
                                      theme.leftDecorationAsset,
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: 24,
                                    child: Image.asset(
                                      theme.rightDecorationAsset,
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.amberAccent,
                                        size: 36,
                                      ),
                                    )
                                  else if (!isUnlocked)
                                    Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme.name,
                                    style: AppTextStyles.subtitle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    theme.description,
                                    style: AppTextStyles.body(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else if (isUnlocked)
                              GlossyButton(
                                label: 'SELECT',
                                width: 85,
                                height: 38,
                                fontSize: 13,
                                onPressed: () => _selectTheme(theme.id),
                              )
                            else
                              GlossyButton(
                                label: '${theme.unlockCostCoins}',
                                icon: Icons.monetization_on,
                                width: 100,
                                height: 38,
                                fontSize: 13,
                                gradientColors: const [Color(0xFFFFA726), Color(0xFFE65100)],
                                onPressed: () => _unlockTheme(theme),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
