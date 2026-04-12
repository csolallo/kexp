class NowPlayingTrack {
    final String title;
    final String artist;
    final String album;
    final DateTime? releaseDate;
    final Uri? coverArtUrl;
    
    NowPlayingTrack({
        required this.title,
        required this.artist,
        required this.album,
        required this.releaseDate,
        this.coverArtUrl,
    });
}