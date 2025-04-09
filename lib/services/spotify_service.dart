import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart'; // For handling redirect URI

import '../models/song.dart';

class SpotifyService {
  final String clientId = '4a7471af32d14275b13b4230583207f7'; // Replace with your client ID
  final String redirectUri = 'musicapp://callback'; // Replace with your redirect URI
  String? _accessToken;

  // Method to connect to Spotify and start OAuth flow
  Future<void> connectToSpotify() async {
    try {
      final bool result = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );

      if (result) {
        print('Connected to Spotify!');
        await _getAccessToken();
      } else {
        print('Failed to connect to Spotify');
      }
    } catch (e) {
      print('Spotify connection error: $e');
    }
  }

  // Method to initiate OAuth and fetch access token
  Future<void> _getAccessToken() async {
    try {
      // Simulate redirect handling via uni_links (for iOS/Android)
      final Uri? initialUri = await getInitialUri();  // Correct way to call getInitialUri
      if (initialUri != null && initialUri.host == 'callback') {
        final String? code = initialUri.queryParameters['code'];
        if (code != null) {
          await _exchangeCodeForToken(code);
        } else {
          print("No authorization code found in the redirect URI.");
        }
      }
    } catch (e) {
      print('Error during OAuth process: $e');
    }
  }

  // Method to exchange authorization code for access token
  Future<void> _exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': '291dece087424b088e2b52b004ba830a', // Replace with your client secret
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        print("Access token obtained: $_accessToken");

        // You can now use this access token to make requests to the Spotify API.
      } else {
        throw Exception('Failed to exchange code for access token');
      }
    } catch (e) {
      print('Error exchanging code for token: $e');
    }
  }

  // Method to fetch tracks by search query
  Future<List<Song>> fetchTracksByQuery(String query) async {
    if (_accessToken == null) {
      throw Exception('No access token. Please connect to Spotify.');
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track&limit=10'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List;

      return tracks.map<Song>((track) {
        return Song(
          songName: track['name'],
          artistName: track['artists'][0]['name'],
          albumArtImagePath: track['album']['images'][0]['url'],
          audioPath: track['preview_url'] ?? '',
          mood: 'Unknown',
        );
      }).toList();
    } else {
      throw Exception('Failed to load Spotify tracks');
    }
  }

  // Example method to fetch the currently playing track (if applicable)
  Future<void> getCurrentTrack() async {
    if (_accessToken == null) {
      throw Exception('No access token. Please connect to Spotify.');
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Current Track: ${data['name']} by ${data['artists'][0]['name']}');
    } else {
      throw Exception('Failed to load currently playing track');
    }
  }
}
