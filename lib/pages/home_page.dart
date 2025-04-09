import 'package:flutter/material.dart';
import 'package:music_player/components/my_drawer.dart';
import 'package:music_player/models/playlist_provider.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import 'mood_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    playlistProvider.currentSongIndex = songIndex;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("S O N G S"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.mood),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoodSelectionPage()),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song> playlist = value.playlist;

          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final Song song = playlist[index];

              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                leading: Container(
                  width: 50,
                  height: 50,
                  child: song.albumArtImagePath.startsWith('http')
                      ? Image.network(
                    song.albumArtImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note),
                  )
                      : Image.asset(
                    song.albumArtImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () => goToSong(index),
              );
            },
          );
        },
      ),
    );
  }
}
