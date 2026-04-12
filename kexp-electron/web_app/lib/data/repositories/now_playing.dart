import 'package:kexp_api/kexp_api.dart';
import 'package:web_app/data/model/now_playing_track.dart';
import 'package:web_app/utils/result.dart';

class NowPlayingRepository {
  final PlayService _service;

  NowPlayingRepository({required PlayService service})
      : _service = service;

  Future<Result<NowPlayingTrack>> fetchCurrentTrack() async {
    PlayRequest request = PlayRequest.currentSongs(false, 1);
    try {
      List<Airing> res = await _service.getPlays(request);
      if (res.isEmpty) {
        return Result.err(Exception("No currently playing track found"));
      }
      Airing airing = res.first;
      NowPlayingTrack track;
      switch (airing.track) {
        case Song song:
          track = AiringUtils.fromSong(song);
          break;
        case NonTrack nonTrack:
          track = AiringUtils.fromNonTrack(nonTrack);
          break;
        default:
          return Result.err(Exception("Unexpected track type: ${airing.track.runtimeType}"));
      }
      return Result.ok(track);
    } catch (e) {
      return Result.err(Exception("Failed to fetch current track: $e"));
    }
  }
}

extension AiringUtils on NowPlayingTrack {
  static NowPlayingTrack fromSong(Song song) {
    return NowPlayingTrack(
      title: song.name,
      artist: song.artist,
      album: song.album ?? "Unknown Album",
      releaseDate: DateTime.tryParse(song.releaseDate),
      coverArtUrl: song.getCoverArtUrl(.large),
    );  
  }

  static NowPlayingTrack fromNonTrack(NonTrack nonTrack) {
    return NowPlayingTrack(
      title: nonTrack.name,
      artist: "Unknown Artist",
      album: "N/A",
      releaseDate: null,
      coverArtUrl: null,
    );
  }
}