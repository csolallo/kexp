import 'package:crypto/crypto.dart';
import 'dart:convert';

enum TrackType { song, nonTrack, airbreak }

abstract class Track {
    String _name;
    TrackType _type;

    String get name => _name;
    TrackType get type => _type;

    String get cacheKey => _name;

    Track(this._name, this._type);
    
    String hashedCacheKey() {
        final bytes = utf8.encode(cacheKey);
        final digest = sha1.convert(bytes);
        return digest.toString();
    }

    Map<String, dynamic> toJson() => {
        'name': _name
    };
}
