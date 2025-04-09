import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/spotify_service.dart';

import 'song.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Song> _currentPlaylist = [];
  int? _currentSongIndex;
  bool _isShuffle = false;
  bool _isRepeat = false;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late final SpotifyService _spotifyService;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlaylistProvider() {
    _spotifyService = SpotifyService();
    _spotifyService.connectToSpotify();  // Connect to Spotify on initialization

    // Listen to duration updates
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    // Listen to position updates
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Auto play next or repeat
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isRepeat) {
        seek(Duration.zero);
        resume();
      } else {
        playNextSong();
      }
    });
  }

  /// Fetch songs based on mood (use Spotify API)
  Future<void> fetchSongsByMood(String mood) async {
    try {
      final songs = await _spotifyService.fetchTracksByQuery(mood);
      _currentPlaylist = songs;
      _currentSongIndex = 0;
      notifyListeners();
      play();
    } catch (e) {
      print('Error fetching Spotify songs: $e');
    }
  }

  Future<void> fetchSongsFromSpotify() async {
    try {
      final songs = await _spotifyService.fetchTracksByQuery("default"); // Use a default query or album
      _currentPlaylist = songs;
      _currentSongIndex = 0;
      notifyListeners();
      play();
    } catch (e) {
      print('Error fetching default songs from Spotify: $e');
    }
  }


  /// Play current song
  void play() async {
    if (_currentSongIndex != null) {
      final String path = _currentPlaylist[_currentSongIndex!].audioPath;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(path));
      _isPlaying = true;
      notifyListeners();
    }
  }

  /// Pause playback
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume playback
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  /// Toggle pause/resume
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }
  /// Play previous song
  void playPreviousSong() {
    if (_currentPlaylist.isEmpty || _currentSongIndex == null) return;

    if (_isShuffle) {
      final randomIndex = Random().nextInt(_currentPlaylist.length);
      _currentSongIndex = randomIndex;
    } else if (_currentSongIndex! > 0) {
      _currentSongIndex = _currentSongIndex! - 1;
    } else {
      _currentSongIndex = _currentPlaylist.length - 1; // Loop back to the last song if at the beginning
    }

    play(); // Call play() method to start playing the previous song
  }

  /// Play next song
  void playNextSong() {
    if (_currentPlaylist.isEmpty || _currentSongIndex == null) return;

    if (_isShuffle) {
      final randomIndex = Random().nextInt(_currentPlaylist.length);
      _currentSongIndex = randomIndex == _currentSongIndex
          ? (randomIndex + 1) % _currentPlaylist.length
          : randomIndex;
    } else {
      _currentSongIndex = (_currentSongIndex! + 1) % _currentPlaylist.length;
    }

    play();
  }

  /// Seek to specific position
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Getters
  List<Song> get playlist => _currentPlaylist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// Set current song index and play
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }

  /// Toggle shuffle
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  /// Toggle repeat
  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }
}
