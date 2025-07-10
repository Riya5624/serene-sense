import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/models/recommendation.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/recommendation_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  // Store the session data we've processed to avoid re-fetching for the same session.
  Map<String, String>? _processedSessionData;

  @override
  void initState() {
    super.initState();
    // Trigger the recommendation generation after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecommendationsIfNeeded();
    });
  }

  /// Checks if new recommendations are needed and triggers the service.
  void _generateRecommendationsIfNeeded() {
    final chatService = context.read<ChatService>();
    final recommendationService = context.read<RecommendationService>();

    final currentSessionData = chatService.lastCompletedSessionData;

    // We generate recommendations only if there's new, unprocessed session data.
    if (currentSessionData.isNotEmpty && currentSessionData != _processedSessionData) {
      _processedSessionData = currentSessionData; // Mark this data as processed.
      recommendationService.generateRecommendations(
        cbtSessionData: currentSessionData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the service to rebuild the UI when its state changes.
    final recommendationService = context.watch<RecommendationService>();

    return Scaffold(
      // The AppBar is already provided by MainNavScreen, keeping the UI clean.
      body: RefreshIndicator(
        onRefresh: () async {
          // Force a regeneration on pull-to-refresh.
          _processedSessionData = null; // Reset processed data to allow re-fetching.
          _generateRecommendationsIfNeeded();
        },
        child: _buildBody(recommendationService),
      ),
    );
  }

  /// Builds the main body of the screen based on the service's current state.
  Widget _buildBody(RecommendationService service) {
    if (service.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Crafting your recommendations...", style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (service.errorMessage.isNotEmpty) {
      return _buildErrorState(service.errorMessage);
    }

    if (service.recommendation == null) {
      return _buildEmptyState();
    }

    final recommendation = service.recommendation!;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAnalysisHeader(recommendation.analysisSummary),
        const SizedBox(height: 24),
        _buildSection('For Your Ears', recommendation.songs),
        const SizedBox(height: 24),
        _buildSection('For Your Body & Mind', recommendation.exercises),
        const SizedBox(height: 24),
        _buildSection('For Your Space', recommendation.tasks),
      ],
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildAnalysisHeader(String summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        summary,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.teal[800]),
      ),
    );
  }

  Widget _buildSection(String title, List<RecommendedItem> items) {
    if (items.isEmpty) return const SizedBox.shrink(); // Don't show empty sections
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 220, // Taller cards look better with this design
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) => _buildRecommendationCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(RecommendedItem item) {
    bool isInteractive = item.youtubeVideoId.isNotEmpty || item.contentUrl.isNotEmpty;

    return Container(
      width: 200, // Slightly narrower cards for a more compact feel
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: InkWell(
          onTap: () => _handleItemTap(context, item),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              if (item.imageUrl.isNotEmpty)
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              // Gradient Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              // Play Button for interactive items
              if (isInteractive)
                const Center(
                  child: Icon(Icons.play_circle_outline_rounded, color: Colors.white70, size: 60),
                ),
              // Text Content
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2)]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 12, shadows: const [Shadow(blurRadius: 2)]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STATE-SPECIFIC UI WIDGETS ---

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(errorMessage, textAlign: TextAlign.center),
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
          const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 50),
          const SizedBox(height: 16),
          const Text(
            'Complete a chat session to get personalized recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                // Pop back to the home screen, allowing user to start a chat
                Navigator.of(context).pop();
              },
              child: const Text("Start a Session"))
        ]),
      ),
    );
  }

  // --- INTERACTION LOGIC ---

  /// Handles tapping a card, deciding whether to play a video or launch a URL.
  void _handleItemTap(BuildContext context, RecommendedItem item) {
    if (item.youtubeVideoId.isNotEmpty) {
      _playYoutubeVideo(context, item.youtubeVideoId);
    } else if (item.contentUrl.isNotEmpty) {
      _launchUrl(item.contentUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _playYoutubeVideo(BuildContext context, String videoId) {
    final YoutubePlayerController controller = YoutubePlayerController(
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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