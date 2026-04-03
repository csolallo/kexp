import 'track_model.dart';

class NonTrack extends Track {
    NonTrack(String name) : super(name, TrackType.nonTrack);

    factory NonTrack.fromJson(Map<String, dynamic> json) {
        return NonTrack(json['song']);
    }
}
