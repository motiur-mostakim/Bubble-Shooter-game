import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/glossy_button.dart';
import '../../data/repositories/player_repository.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final PlayerRepository playerRepository;

  const OnboardingScreen({super.key, required this.playerRepository});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Aim & Pop Bubbles!',
      'subtitle':
          'Drag to aim your magic cannon and shoot. Match 3 or more bubbles of the same color to burst them!',
      'icon': Icons.ads_click,
      'color': const Color(0xFFFF4B4B),
    },
    {
      'title': 'Explore Fantasy Worlds',
      'subtitle':
          'Journey through Magic Forest, Ocean World, Candy Land, Galaxy World, Fairy Kingdom & Winter Wonderland!',
      'icon': Icons.public,
      'color': const Color(0xFF00E5FF),
    },
    {
      'title': 'Unlock Epic Power-ups',
      'subtitle':
          'Use Bomb Bubbles, Rainbow Wildcards, and Lightning Bolts to overcome challenging levels!',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFFFFD54F),
    },
  ];

  Future<void> _completeOnboarding() async {
    final player = await widget.playerRepository.loadPlayer();
    final updated = player.copyWith(onboardingCompleted: true);
    await widget.playerRepository.savePlayer(updated);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(playerRepository: widget.playerRepository),
      ),
    );
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
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() => _currentPage = idx);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item['color'].withValues(alpha: 0.2),
                              border: Border.all(color: item['color'], width: 3),
                            ),
                            child: Icon(
                              item['icon'],
                              size: 70,
                              color: item['color'],
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            item['title'],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title(fontSize: 26),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['subtitle'],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (idx) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == idx ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == idx
                          ? AppColors.coinGold
                          : Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: GlossyButton(
                  label: _currentPage == _pages.length - 1
                      ? 'GET STARTED'
                      : 'NEXT',
                  width: 220,
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
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
