import 'track_model.dart';

enum CoverArtSize { small, large }

class SongBuilder {
    String? _name;
    String? _album;
    String? _artist;
    String? _releaseDate;

    Uri? _smallCoverArtUrl;
    Uri? _largeCoverArtUrl;

    set name(String? name) => _name = name;
    set album(String? album) => _album = album;
    set artist(String? artist) => _artist = artist;
    set releaseDate(String? releaseDate) => _releaseDate = releaseDate;
    set smallCoverArtUrl(Uri? url) => _smallCoverArtUrl = url;
    set largeCoverArtUrl(Uri? url) => _largeCoverArtUrl = url;

    Song build() {
        return Song(
            _name ?? 'Unknown',
            _album,
            _artist ?? 'Unknown Artist',
            _releaseDate ?? 'Unknown Release Date',
            _smallCoverArtUrl,
            _largeCoverArtUrl
        );
    }
}

class Song extends Track {
    String? _album;
    String _artist;
    String _releaseDate;

    Uri? _smallCoverArtUrl;
    Uri? _largeCoverArtUrl;

    String? get album => _album;
    String get artist => _artist;
    String get releaseDate => _releaseDate;
    
    @override
    String get cacheKey => name + artist + (_album ?? '');

    Song(
        String name,
        String? album,
        String artist,
        String releaseDate,
        Uri? smallCoverArtUrl,
        Uri? largeCoverArtUrl,
    ) : 
        _album = album,
        _artist = artist,
        _releaseDate = releaseDate,
        _smallCoverArtUrl = smallCoverArtUrl,
        _largeCoverArtUrl = largeCoverArtUrl,
        super(name, TrackType.song);

    factory Song.fromJson(Map<String, dynamic> json) {
        SongBuilder builder = SongBuilder()
            ..name = json['song'] as String?
            ..album = json['album'] as String?
            ..artist = json['artist'] as String?
            ..releaseDate = json['release_date'] as String?
            ..smallCoverArtUrl = json['thumbnail_uri'] != null
                ? Uri.parse(json['thumbnail_uri'])
                : null
            ..largeCoverArtUrl = json['image_uri'] != null
                ? Uri.parse(json['image_uri'])
                : null;

        return builder.build();
    }

    Uri? getCoverArtUrl(CoverArtSize size) {
        switch (size) {
        case CoverArtSize.small:
            return _smallCoverArtUrl;
        case CoverArtSize.large:
            return _largeCoverArtUrl;
        }
    }

    @override
    Map<String, dynamic> toJson() => {
        'name': super.name,
        'album': _album ?? 'Unknown Album',
        'artist': _artist,
        'release_date': _releaseDate,
        'cover_art_small': _smallCoverArtUrl?.toString(),
        'cover_art_large': _largeCoverArtUrl?.toString(),
    };
}
