// lib/screens/recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serene_sense/models/recommendation.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/recommendation_service.dart';
import 'package:serene_sense/services/tts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  Map<String, String>? _processedSessionData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateRecommendationsIfNeeded());
  }

  /// Checks if new recommendations are needed and triggers the service.
  void _generateRecommendationsIfNeeded() {
    final chatService = context.read<ChatService>();
    final recService = context.read<RecommendationService>();
    final currentSessionData = chatService.lastCompletedSessionData;

    if (currentSessionData.isNotEmpty && currentSessionData != _processedSessionData) {
      _processedSessionData = currentSessionData;
      recService.generateRecommendations(sessionData: currentSessionData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recService = context.watch<RecommendationService>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          _processedSessionData = null; // Allow re-fetching
          _generateRecommendationsIfNeeded();
        },
        child: _buildBody(recService),
      ),
    );
  }

  /// Builds the main body of the screen based on the service's current state.
  Widget _buildBody(RecommendationService service) {
    if (service.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Crafting your recommendations...",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    if (service.errorMessage != null) {
      return _buildErrorState(service.errorMessage!);
    }

    if (service.items.isEmpty) {
      return _buildEmptyState();
    }

    // Group items by their type for sectioned display
    final songs = service.items.where((i) => i.type == ItemType.song).toList();
    final exercises = service.items.where((i) => i.type == ItemType.exercise).toList();
    final guidedImageries = service.items.where((i) => i.type == ItemType.guidedImagery).toList();
    final tasks = service.items.where((i) => i.type == ItemType.task).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          "For You",
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          "Personalized suggestions based on your reflection.",
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        _buildSection("For Your Ears", songs),
        _buildSection("Guided Imagery", guidedImageries),
        _buildSection("Mindful Exercises", exercises),
        _buildSection("Actionable Tasks", tasks),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSection(String title, List<RecommendedItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...items.map((item) => _RecommendationCard(item: item))
            .toList()
            .animate(interval: 100.ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.2),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text("Something went wrong", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center, style: GoogleFonts.lato()),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                _processedSessionData = null;
                _generateRecommendationsIfNeeded();
              },
              child: const Text("Try Again"))
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 60),
          const SizedBox(height: 20),
          Text('No Recommendations Yet', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('Complete a guided chat session to unlock your personalized recommendations.', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}

/// A dedicated, interactive card for a single recommendation item.
class _RecommendationCard extends StatelessWidget {
  final RecommendedItem item;
  const _RecommendationCard({required this.item});

  IconData _getIconForType(ItemType type) {
    switch (type) {
      case ItemType.song: return Icons.music_note_rounded;
      case ItemType.exercise: return Icons.fitness_center_rounded;
      case ItemType.guidedImagery: return Icons.self_improvement_rounded;
      case ItemType.task: return Icons.task_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the TTS service to update the play/stop button state
    final ttsService = context.watch<TtsService>();
    final bool isThisItemPlaying = ttsService.isPlaying && ttsService.currentlyPlayingId == item.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_getIconForType(item.type), color: Theme.of(context).primaryColor, size: 32),
              title: Text(item.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(item.description, style: GoogleFonts.lato(fontSize: 15, height: 1.5, color: Colors.black87)),
            ),
            if (item.steps.isNotEmpty)
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text("Show Steps", style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                children: item.steps.map((step) => ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.grey),
                  title: Text(step, style: GoogleFonts.lato()),
                )).toList(),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(isThisItemPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
                  color: isThisItemPlaying ? Colors.red.shade600 : Theme.of(context).primaryColor,
                  tooltip: isThisItemPlaying ? "Stop" : "Listen to Description & Steps",
                  onPressed: () => ttsService.speak(item.speakableText, item.id),
                ),
                if (item.contentUrl != null || item.youtubeVideoId != null)
                  IconButton(
                    icon: Icon(item.youtubeVideoId != null ? Icons.play_circle_outline : Icons.open_in_new_rounded),
                    color: Theme.of(context).primaryColor,
                    tooltip: item.youtubeVideoId != null ? "Play Video" : "Open Link",
                    onPressed: () {
                      if (item.youtubeVideoId != null) {
                        _playYoutubeVideo(context, item.youtubeVideoId!);
                      } else if (item.contentUrl != null) {
                        _launchUrl(context, item.contentUrl!);
                      }
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  void _playYoutubeVideo(BuildContext context, String videoId) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              onEnded: (_) => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}