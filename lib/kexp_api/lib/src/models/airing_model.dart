import 'package:intl/intl.dart';

import '../utils/command_logger.dart';
import 'airbreak_model.dart';
import 'nontrack_model.dart';
import 'song_model.dart';
import 'track_model.dart';

class Airing {
    // intrinsic data
    static final Map<String, Track> _cache = {};
    
    String? _trackRef;
    DateTime _airDate;

    Track? get track {
        if (_cache.containsKey(_trackRef)) {
            return _cache[_trackRef];
        }
        return null;
    }

    DateTime get airDate => _airDate;

    Airing(String trackRef, DateTime airDate) : _trackRef = trackRef, _airDate = airDate;
   
    factory Airing.fromJson(Map<String, dynamic> json) {
        try {
            CommandLogger.getInstance().info("processing id: ${json['id']}");
            Track track = switch (json['play_type']) {
                'trackplay' => Song.fromJson(json),
                'airbreak' => Airbreak(),
                'nontrackplay' => NonTrack.fromJson(json),
                _ => throw Exception("Unknown play_type: ${json['play_type']}"),
            };
            
            final key = track.hashedCacheKey();
            _cache.putIfAbsent(key, () => track);
                
            final airdate = DateTime.parse(json['airdate']);
            return Airing(
                key,
                airdate,
            );
        } on FormatException catch (e) {
            CommandLogger.getInstance().error("Error parsing airdate: ${json['airdate']}. Error: $e");
            rethrow;
        } on Exception catch (_) {
            CommandLogger.getInstance().error("Unknown play type: ${json['play_type']}");
            rethrow;
        }
    }

    Map<String, dynamic> toJson() {
        Track? track = _cache[_trackRef];
        DateFormat formatter = DateFormat("yyyy-MM-ddTHH:mm:ss");
        return {
            'track': track?.toJson(),
            'air_date': formatter.format(_airDate.toLocal())
        };
    }
}
