import 'package:flutter/material.dart';
import 'package:music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class MoodSelectionPage extends StatelessWidget {
  const MoodSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Mood')),
      body: ListView(
        children: [
          _buildMoodTile(context, 'Happy', playlistProvider),
          _buildMoodTile(context, 'Sad', playlistProvider),
          _buildMoodTile(context, 'Energetic', playlistProvider),
          _buildMoodTile(context, 'Relaxed', playlistProvider),
          ListTile(
            title: const Text('Reset to All Songs'),
            onTap: () {
              playlistProvider.fetchSongsFromSpotify();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTile(BuildContext context, String mood, PlaylistProvider provider) {
    return ListTile(
      title: Text(mood),
      onTap: () {
        provider.fetchSongsByMood(mood);
        Navigator.pop(context);
      },
    );
  }
}