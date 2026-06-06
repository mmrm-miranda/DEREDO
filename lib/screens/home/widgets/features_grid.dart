import 'package:flutter/material.dart';
import '../models/feature_item.dart';
import 'feature_card.dart';

class FeaturesGrid extends StatelessWidget {
  final List<FeatureItem> items;
  final void Function(FeatureItem) onItemTap;

  const FeaturesGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => FeatureCard(
          item: items[i],
          onTap: () => onItemTap(items[i]),
        ),
      ),
    );
  }
}
