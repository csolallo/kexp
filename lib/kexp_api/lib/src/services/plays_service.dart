import 'package:args/args.dart';
import 'package:format/format.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../models/airing_model.dart';
import '../utils/command_logger.dart';
import '../utils/int_extensions.dart';

class PlayRequest {
    bool includeAirBreaks;
    int? numberOfTracks;
    String? startAirDate;
    String? endAirDate;

    static final RegExp _re = RegExp(r'[/-]?(\d+)');

    PlayRequest(this.includeAirBreaks, this.numberOfTracks, this.startAirDate, this.endAirDate);

    PlayRequest.currentSongs(bool includeAirBreaks, int? numberOfTracks) : this(includeAirBreaks, numberOfTracks, null, null);

    factory PlayRequest.fromArgResults(ArgResults argResults) {
        bool includeAirBreaks = argResults['air-breaks'] as bool? ?? false;
        int? numberOfTracks = int.tryParse(argResults['number'] as String? ?? '');
        String? startAirDate = argResults['start-date'] != null
            ? _urlEncodedDate(argResults['start-date'] as String)
            : null;
        String? endAirDate = argResults['end-date'] != null
            ? _urlEncodedDate(argResults['end-date'] as String)
            : null;

        if (numberOfTracks == null && startAirDate == null && endAirDate == null) {
            // default to current songs if no parameters given
            throw Exception();
        }
        
        switch ((numberOfTracks, startAirDate, endAirDate)) {
            case (null, null, null):
                throw Exception("Number of tracks and/or start and end dates must be provided.");
            case (int _, null, String _):
            case (int _, String _, null):
                throw Exception("Both start and end dates must be provided.");
            default:
                // no op
            }

        return PlayRequest(
            includeAirBreaks,
            numberOfTracks,
            startAirDate,
            endAirDate,
        );
    }

    static String? _urlEncodedDate(String dateString) {
        if (dateString.contains('T')) {
            // assume it's already in a valid format
            return Uri.encodeComponent(dateString);
        }

        final dateSegments = _re.allMatches(dateString);
        String? year, month, day;

        if (dateSegments.length == 3) {
            // year
            RegExpMatch match = dateSegments.elementAt(0);
            year = match[1];
            
            // month
            match = dateSegments.elementAt(1);
            month = match[1];

            // day
            match = dateSegments.elementAt(2);
            day = match[1];

            final local = DateTime(int.parse(year!), int.parse(month!), int.parse(day!));
            final offset =local.timeZoneOffset.inHours;

            final localDateString = format('{year}-{month:02}-{day:02}T00:00:00{offset:03}00',{
                'year': year, 
                'month': month, 
                'day': day, 
                'offset': offset
            });
         
            return Uri.encodeComponent(localDateString);
        }

        return null;
    }
}
 
class PlayService {
    static const String playUrl = "https://api.kexp.org/v2/plays/";
    static const String querystringTemplate = "?airdate_after={startDate}&airdate_before={endDate}&has_comment=&exclude_airbreaks={excludeAirBreaks}&exclude_non_songs=&show_ids=&host_ids=&playlist_location=&song=&song_exact=&artist=&artist_exact=&album=&album_exact=&label=&label_exact=&recording_id=&limit={count}&ordering=-airdate";
    
    final http.Client _client;

    PlayService({http.Client? client}) : _client = client ?? http.Client();
    
    Future<List<Airing>> getPlays(PlayRequest request) async {
        final querystring = querystringTemplate
            .replaceAll("{startDate}", request.startAirDate ?? "")
            .replaceAll("{endDate}", request.endAirDate ?? "")
            .replaceAll("{excludeAirBreaks}", (!request.includeAirBreaks).toString())
            .replaceAll("{count}", request.numberOfTracks?.toString() ?? "");

        final url = Uri.parse(playUrl + querystring);
        CommandLogger.getInstance().info("starting Url:\n$url");

        List<Airing> results = List.empty(growable: true);
        await _buildList(results, request.numberOfTracks ?? IntExtensions.maxint, url);
        _client.close();
        return results;
    }

    Future <void> _buildList(List<Airing> results, int maxResults, Uri url) async {
        try {
            final response = await _client.get(url);
            if (response.statusCode == 200) {
                final bodyString = utf8.decode(response.bodyBytes);
                final data = jsonDecode(bodyString) as Map<String, dynamic>;
                if (data['results'] is List<dynamic>) {
                    // termination condition
                    if ((data['results'] as List).isEmpty) {
                        return;
                    }
                    
                    final List<Airing> pageResults = data['results']
                        .map(
                            (playData) => (playData is Map<String, dynamic>)
                                ? Airing.fromJson(playData)
                                : null,
                        )
                        .whereType<Airing>()
                        .toList();                

                    for (final airing in pageResults) {
                        if (results.length <= maxResults) {
                            results.add(airing);
                            continue;
                        } 
                        break;
                    }
                    
                    if (results.length < maxResults && data['next'] != null) {
                        CommandLogger.getInstance().info("next page:\n${data['next']}");
                        final nextUrl = Uri.parse(data['next']);
                       await _buildList(results, maxResults, nextUrl);
                    }
                }
            }
        } catch (e) {
             CommandLogger.getInstance().error("an error occurred: $e");
             rethrow;
        }
    }
}
