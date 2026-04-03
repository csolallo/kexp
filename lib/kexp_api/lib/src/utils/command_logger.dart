import 'package:logging/logging.dart';

class CommandLogger {
    static CommandLogger? _instance;

    Logger? _warningLogger;
    Logger? _infoLogger;
 
    CommandLogger._internal() {
        hierarchicalLoggingEnabled = true;
        
        Logger.root.level = Level.SEVERE;
        Logger.root.onRecord.listen((record) {
            print('${record.level.name}: ${record.time}: ${record.message}');
        });
    }

    factory CommandLogger() {
        _instance ??= CommandLogger._internal();
        return _instance!;
    }

    void configure(Level logLevel) {
        switch (logLevel) {
            case Level.INFO:
                _createInfoLogger(); // fall-through to also create warning logger
            case Level.WARNING:
                _createWarningLogger();
            default:
                // no op
        }
    }

    static CommandLogger getInstance() => CommandLogger();

    void _createInfoLogger() {
        _infoLogger = Logger('infoLogger');
        _infoLogger!.level = Level.INFO;
        _infoLogger!.onRecord.listen((record) {
            if (record.level == Level.INFO) {
                print('${record.level.name}: ${record.time}: ${record.message}');
            }
        });
    }

    void _createWarningLogger() {
        _warningLogger = Logger('warningLogger');
        _warningLogger!.level = Level.WARNING;
        _warningLogger!.onRecord.listen((record) {
            if (record.level == Level.WARNING) {
                print('${record.level.name}: ${record.time}: ${record.message}');
            }
        });
    }

    void error(String message) {
        Logger.root.severe(message);
    }

    void info(String message) {
        _infoLogger?.info(message);
    }

    void warning(String message) {
        _warningLogger?.warning(message);
    }
}