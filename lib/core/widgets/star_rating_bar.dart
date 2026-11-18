import 'package:flutter/material.dart';

class StarRatingBar extends StatelessWidget {
  final int stars;
  final double starSize;

  const StarRatingBar({
    super.key,
    required this.stars,
    this.starSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amberAccent : Colors.grey,
            size: starSize,
          ),
        );
      }),
    );
  }
}
