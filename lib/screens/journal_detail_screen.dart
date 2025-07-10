// lib/screens/journal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(entry.timestamp)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMoodCard(context),
          const SizedBox(height: 20),
          _buildContentCard(context),
          const SizedBox(height: 20),
          if (entry.sentimentScore != null) _buildAnalysisCard(context),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'You felt',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 8),
            Text(
              entry.mood.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Thoughts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            Text(
              entry.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context) {
    // Normalize score from [-1, 1] to [0, 1] for the progress indicator
    final normalizedScore = (entry.sentimentScore! + 1) / 2;
    final scoreColor = Color.lerp(Colors.red, Colors.green, normalizedScore)!;
    String scoreLabel;
    if (normalizedScore > 0.6) {
      scoreLabel = 'Positive';
    } else if (normalizedScore < 0.4) {
      scoreLabel = 'Negative';
    } else {
      scoreLabel = 'Neutral';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sentiment:', style: Theme.of(context).textTheme.titleMedium),
                Text(scoreLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scoreColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: normalizedScore,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
             const SizedBox(height: 8),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('More Negative', style: Theme.of(context).textTheme.bodySmall),
                  Text('More Positive', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}