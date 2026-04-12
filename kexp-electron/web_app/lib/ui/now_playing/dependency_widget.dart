import 'package:flutter/material.dart';
import 'package:web_app/ui/now_playing/view_model.dart';

class DependencyWidget extends InheritedWidget {
  final NowPlayingViewModel _viewModel;

  NowPlayingViewModel get viewModel => _viewModel;

  const DependencyWidget({
    super.key,
    required NowPlayingViewModel viewModel,
    required super.child,
  }) : _viewModel = viewModel;

  static DependencyWidget of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<DependencyWidget>();
    assert(result != null, 'No DependencyWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DependencyWidget oldWidget) => _viewModel != oldWidget._viewModel;
}