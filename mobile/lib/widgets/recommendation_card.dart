import 'package:flutter/material.dart';
import 'package:touristai/services/recommendation_service.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({required this.result, super.key});

  final RecommendationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(result.summary),
            const SizedBox(height: 12),
            for (final item in result.recommendations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.suggestedOrder}. ${item.placeName}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(item.reason),
                    Text(item.tip),
                  ],
                ),
              ),
            Text(result.generalTip),
          ],
        ),
      ),
    );
  }
}
