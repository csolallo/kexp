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
    return Container();
  }
}