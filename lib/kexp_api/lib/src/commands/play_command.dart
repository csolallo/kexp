import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';

import 'dart:convert';

import '../services/plays_service.dart';
import '../utils/command_logger.dart';

class PlayCommand extends Command<int>{
    @override
    String get description => 'Search for plays based on various criteria.';
  
    @override
    String get name => 'plays';

    PlayCommand() : super() {
        argParser
          ..addFlag('air-breaks', abbr: 'b', negatable: true, help: 'Include air breaks in results.')
          ..addOption('number', abbr: 'n', help: 'Number of tracks to retrieve.')
          ..addOption('start-date', abbr: 's', help: 'earliest air date for a date range. Format: YYYY-MM-DD')
          ..addOption('end-date', abbr: 'e', help: 'latest air date for a date range. Format: YYYY-MM-DD')
          ..addOption('log-level', abbr: 'l', help: 'Set the logging level (e.g. info, warning, error).', defaultsTo: 'error');
    }

    @override
    Future<int> run() async {
        PlayService playService = PlayService();
        PlayRequest request = PlayRequest.fromArgResults(argResults!);
      
        if (argResults!['log-level'] != null) {
            final logLevel = argResults!['log-level'].toString().toLowerCase();
            switch (logLevel) {
                case 'info':
                    CommandLogger.getInstance().configure(Level.INFO);
                    break;
                case 'warning':
                    CommandLogger.getInstance().configure(Level.WARNING);
                   break;
                default:
                    // no op
            }
        }

        var results = await playService.getPlays(request);

        // TODO move this to a renderer class
        final encoder = const JsonEncoder.withIndent('  ');
        final Map<String, List<Map<String, dynamic>>> resultsMap = {
            "results": results.map((airing) => airing.toJson()).toList(),
        };

        final prettyJson = encoder.convert(resultsMap);
        print(prettyJson);
        return 0;
    }
}
