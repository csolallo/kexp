import 'package:flutter/material.dart';
import 'package:web_app/data/model/now_playing_track.dart';
import 'package:web_app/data/repositories/now_playing.dart';
import 'package:web_app/utils/result.dart';

import 'dart:developer';

class NowPlayingViewModel extends ChangeNotifier {

  NowPlayingViewModel({
    required NowPlayingRepository repository,
  }) : 
    _repository = repository;

  final NowPlayingRepository _repository;

  NowPlayingTrack? _currentTrack;
  NowPlayingTrack? get currentTrack => _currentTrack;

  // command methods 
  
  Future <void> load() async {
    final nowPlayingResult = await _repository.fetchCurrentTrack();
    switch (nowPlayingResult) {
      case Ok(value: var v):
        _currentTrack = v;
        break;
      case Err(error: var err):
        _currentTrack = null;
        log("Error fetching current track: $err");
    }
    notifyListeners();
  }
}