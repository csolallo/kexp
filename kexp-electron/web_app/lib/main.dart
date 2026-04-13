import 'package:flutter/material.dart';
import 'package:kexp_api/kexp_api.dart';
import 'package:web_app/data/repositories/now_playing.dart';
import 'package:web_app/ui/now_playing/dependency_widget.dart';
import 'package:web_app/ui/now_playing/now_playing_screen.dart';
import 'package:web_app/ui/now_playing/view_model.dart';

import 'ipc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp() : super(key: null);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KEXP Now Playing',
      theme: ThemeData(
         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Builder(
        builder: (BuildContext context) {
        PlayService service = PlayService();
        var repository = NowPlayingRepository(service: service); 
        var viewModel = NowPlayingViewModel(repository: repository);

        return DependencyWidget(
            viewModel: viewModel,
            child: NowPlayingView()
        ); 
      })
    );
  }
}
