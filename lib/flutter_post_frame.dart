import 'dart:async';
import 'package:flutter/widgets.dart';

export 'post_frame_builder.dart';
export 'post_frame_scroll_builder.dart';

mixin FlutterPostFrameMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) onAfterBuildFrame(context);
    });
  }

  FutureOr<void> onAfterBuildFrame(BuildContext context);
}
