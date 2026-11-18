import 'package:flutter/material.dart';
import '../../data/models/theme_model.dart';
import '../../data/static_data/themes_data.dart';
import 'environment_particles.dart';

class ThemeEnvironmentWidget extends StatelessWidget {
  final ThemeModel theme;
  final Widget child;

  ThemeEnvironmentWidget({
    super.key,
    ThemeModel? theme,
    required this.child,
  }) : theme = theme ?? ThemesData.themes.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Responsive decoration widths and heights
        final sideDecorWidth = (screenWidth * 0.22).clamp(70.0, 130.0);
        final bottomDecorHeight = (screenHeight * 0.16).clamp(90.0, 160.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Base Environment Sky Background
            Image.asset(
              theme.skyAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.gradientBackground,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Layer 2: Distant Scenery (Clouds / Mountain silhouettes)
            IgnorePointer(
              child: Image.asset(
                theme.distantAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

            // Layer 3: Midground Scenery (Mountains / Water lake / Midground trees)
            IgnorePointer(
              child: Image.asset(
                theme.midgroundAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

            // Layer 4a: Left Side Decoration (Temple pillars / Hanging foliage)
            Positioned(
              left: 0,
              top: 0,
              bottom: bottomDecorHeight * 0.5,
              width: sideDecorWidth,
              child: IgnorePointer(
                child: Image.asset(
                  theme.leftDecorationAsset,
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Layer 4b: Right Side Decoration
            Positioned(
              right: 0,
              top: 0,
              bottom: bottomDecorHeight * 0.5,
              width: sideDecorWidth,
              child: IgnorePointer(
                child: Image.asset(
                  theme.rightDecorationAsset,
                  fit: BoxFit.fill,
                  alignment: Alignment.topRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Layer 5: Bubble Gameplay Area (Flame Game canvas)
            child,

            // Layer 6: Foreground Bottom Decoration (Stone platform, grass ground, seabed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomDecorHeight,
              child: IgnorePointer(
                child: Image.asset(
                  theme.bottomDecorationAsset,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Layer 7: Animated Environmental Particles (Leaves, sparkles, fireflies, snow)
            IgnorePointer(
              child: EnvironmentParticlesWidget(
                particleType: theme.particleType,
                colors: theme.particleColors,
                particleCount: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}
