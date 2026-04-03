import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:kexp_api/kexp_api.dart';

const String version = '0.0.1';

class KexpCommandRunner extends CommandRunner<int> {

    KexpCommandRunner()
        : super('kexp_cli', 'A CLI tool for KEXP data') {
        argParser.addFlag('version', negatable: false, help: 'Print the tool version.');
    }

    @override
    Future<int?> runCommand(ArgResults topLevelResults) async {
        if (topLevelResults['version'] == true) {
        print('kexp_cli version $version');
        return null;
        }
        return super.runCommand(topLevelResults);
    }
}

void main(List<String> arguments) async{
  CommandRunner<int> runner = KexpCommandRunner()
    ..addCommand(PlayCommand()); 

  await runner.run(arguments).catchError((error) {
    print('Error: $error');
    print('');
    return -1;
  });
}
