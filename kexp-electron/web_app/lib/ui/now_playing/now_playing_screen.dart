import 'package:flutter/material.dart';
import 'package:web_app/ui/now_playing/dependency_widget.dart';
import 'package:web_app/ui/now_playing/view_model.dart';

class NowPlayingView extends StatefulWidget {
  const NowPlayingView({super.key, this.child});

  final Widget? child;

  @override
  State<NowPlayingView> createState() => _NowPlayingViewState();
}

class _NowPlayingViewState extends State<NowPlayingView> {
  late NowPlayingViewModel? viewModel;

  @override
  void didChangeDependencies() {
    viewModel = context.dependOnInheritedWidgetOfExactType<DependencyWidget>()!.viewModel;
    viewModel!.load();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: viewModel!, 
        builder: (BuildContext context, Widget? _) {
          bool hasCoverArt = false;  
          if (viewModel?.currentTrack?.coverArtUrl case Uri? uri when uri != null && uri.toString().isNotEmpty) {
            hasCoverArt = true;
          }
          return Align(
            alignment: .topLeft,
            child: Container(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  
              children: [
                Visibility(
                  visible: hasCoverArt,
                  replacement: Image.asset(
                    "assets/images/kexp_banner.png",
                    scale: 0.5,
                  ),
                  child: Image.network(
                    viewModel?.currentTrack?.coverArtUrl?.toString() ?? "",
                    width: 500,
                    height: 500
                  )
                )
              ],
            ),
          )
        ); 
      }
    );
  }
}
