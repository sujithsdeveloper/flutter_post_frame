import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_post_frame/flutter_post_frame.dart';

class PostFrameBuilder extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function(BuildContext context, Size? size)
  onAfterBuildFrame;

  const PostFrameBuilder({
    super.key,
    required this.child,
    required this.onAfterBuildFrame,
  });

  @override
  State<PostFrameBuilder> createState() => _PostFrameBuilderState();
}

class _PostFrameBuilderState extends State<PostFrameBuilder>
    with FlutterPostFrameMixin<PostFrameBuilder> {
  Size? _widgetSize;

  @override
  FutureOr<void> onAfterBuildFrame(BuildContext context) async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    _widgetSize = renderBox?.size;
    await widget.onAfterBuildFrame(context, _widgetSize);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
