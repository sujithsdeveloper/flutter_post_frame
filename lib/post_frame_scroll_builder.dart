import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_post_frame/flutter_post_frame.dart';

/// A controller that manages multiple [ScrollController]s with unique keys.
///
/// This class provides a convenient way to create, access, and manage multiple
/// scroll controllers in a single widget tree.
///
/// Example:
/// ```dart
/// final scrollManager = PostFrameScrollManager();
///
/// // Create controllers
/// scrollManager.createController('list1');
/// scrollManager.createController('list2', initialScrollOffset: 100);
///
/// // Access controllers
/// final controller1 = scrollManager['list1'];
///
/// // Scroll to position
/// scrollManager.animateTo('list1', 500, duration: Duration(milliseconds: 300));
/// ```
class PostFrameScrollManager {
  final Map<String, ScrollController> _controllers = {};
  final Map<String, List<VoidCallback>> _scrollListeners = {};

  /// Creates a new [ScrollController] with the given [key].
  ///
  /// If a controller with the same key already exists, it will be disposed
  /// and replaced with a new one.
  ///
  /// [initialScrollOffset] - The initial scroll offset of the controller.
  /// [keepScrollOffset] - Whether to keep the scroll offset when the controller
  /// is disposed and recreated.
  ScrollController createController(
    String key, {
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
  }) {
    // Dispose existing controller if any
    if (_controllers.containsKey(key)) {
      _controllers[key]!.dispose();
    }

    final controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
    );

    _controllers[key] = controller;
    return controller;
  }

  /// Gets a [ScrollController] by its [key].
  ///
  /// Returns `null` if no controller exists with the given key.
  ScrollController? getController(String key) => _controllers[key];

  /// Gets a [ScrollController] by its [key] using bracket notation.
  ///
  /// Returns `null` if no controller exists with the given key.
  ScrollController? operator [](String key) => _controllers[key];

  /// Returns all registered controller keys.
  Iterable<String> get keys => _controllers.keys;

  /// Returns all registered controllers.
  Iterable<ScrollController> get controllers => _controllers.values;

  /// Returns the number of registered controllers.
  int get length => _controllers.length;

  /// Checks if a controller with the given [key] exists.
  bool hasController(String key) => _controllers.containsKey(key);

  /// Adds a scroll listener to the controller with the given [key].
  ///
  /// Returns `true` if the listener was added successfully.
  bool addScrollListener(String key, VoidCallback listener) {
    final controller = _controllers[key];
    if (controller == null) return false;

    controller.addListener(listener);
    _scrollListeners.putIfAbsent(key, () => []).add(listener);
    return true;
  }

  /// Removes a scroll listener from the controller with the given [key].
  ///
  /// Returns `true` if the listener was removed successfully.
  bool removeScrollListener(String key, VoidCallback listener) {
    final controller = _controllers[key];
    if (controller == null) return false;

    controller.removeListener(listener);
    _scrollListeners[key]?.remove(listener);
    return true;
  }

  /// Removes all scroll listeners from the controller with the given [key].
  void removeAllScrollListeners(String key) {
    final controller = _controllers[key];
    final listeners = _scrollListeners[key];
    if (controller == null || listeners == null) return;

    for (final listener in listeners) {
      controller.removeListener(listener);
    }
    _scrollListeners[key]?.clear();
  }

  /// Gets the current scroll offset of the controller with the given [key].
  ///
  /// Returns `null` if no controller exists or if it's not attached.
  double? getScrollOffset(String key) {
    final controller = _controllers[key];
    if (controller == null || !controller.hasClients) return null;
    return controller.offset;
  }

  /// Gets the max scroll extent of the controller with the given [key].
  ///
  /// Returns `null` if no controller exists or if it's not attached.
  double? getMaxScrollExtent(String key) {
    final controller = _controllers[key];
    if (controller == null || !controller.hasClients) return null;
    return controller.position.maxScrollExtent;
  }

  /// Gets the min scroll extent of the controller with the given [key].
  ///
  /// Returns `null` if no controller exists or if it's not attached.
  double? getMinScrollExtent(String key) {
    final controller = _controllers[key];
    if (controller == null || !controller.hasClients) return null;
    return controller.position.minScrollExtent;
  }

  /// Animates the scroll position to [offset] for the controller with [key].
  ///
  /// Returns a [Future] that completes when the animation finishes.
  /// Returns `null` if the controller doesn't exist or isn't attached.
  Future<void>? animateTo(
    String key,
    double offset, {
    required Duration duration,
    Curve curve = Curves.easeInOut,
  }) {
    final controller = _controllers[key];
    if (controller == null || !controller.hasClients) return null;
    return controller.animateTo(offset, duration: duration, curve: curve);
  }

  /// Jumps the scroll position to [offset] for the controller with [key].
  ///
  /// Returns `true` if successful, `false` otherwise.
  bool jumpTo(String key, double offset) {
    final controller = _controllers[key];
    if (controller == null || !controller.hasClients) return false;
    controller.jumpTo(offset);
    return true;
  }

  /// Scrolls to the top of the scrollable for the controller with [key].
  Future<void>? scrollToTop(
    String key, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return animateTo(key, 0, duration: duration, curve: curve);
  }

  /// Scrolls to the bottom of the scrollable for the controller with [key].
  Future<void>? scrollToBottom(
    String key, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final maxExtent = getMaxScrollExtent(key);
    if (maxExtent == null) return null;
    return animateTo(key, maxExtent, duration: duration, curve: curve);
  }

  /// Disposes a single controller with the given [key].
  void disposeController(String key) {
    removeAllScrollListeners(key);
    _controllers[key]?.dispose();
    _controllers.remove(key);
    _scrollListeners.remove(key);
  }

  /// Disposes all controllers managed by this manager.
  void dispose() {
    for (final key in _controllers.keys.toList()) {
      disposeController(key);
    }
  }
}

/// Data class containing post-frame build information including scroll controllers.
class PostFrameScrollData {
  /// The build context of the widget.
  final BuildContext context;

  /// The size of the widget after the first frame.
  final Size? size;

  /// The scroll controller manager for accessing multiple controllers.
  final PostFrameScrollManager scrollManager;

  const PostFrameScrollData({
    required this.context,
    required this.size,
    required this.scrollManager,
  });
}

/// A widget that provides post-frame callbacks with multiple scroll controller support.
///
/// This widget combines the functionality of [PostFrameBuilder] with
/// [PostFrameScrollManager] to provide a convenient way to:
/// - Execute code after the first frame is rendered
/// - Manage multiple scroll controllers
/// - Access the widget's BuildContext and size
///
/// Example:
/// ```dart
/// PostFrameScrollBuilder(
///   controllerKeys: ['list1', 'list2'],
///   onAfterBuildFrame: (data) {
///     // Access controllers
///     final controller1 = data.scrollManager['list1'];
///
///     // Get widget size
///     print('Size: ${data.size}');
///
///     // Scroll to position
///     data.scrollManager.animateTo('list1', 100,
///       duration: Duration(milliseconds: 300));
///   },
///   builder: (context, scrollManager) {
///     return Column(
///       children: [
///         Expanded(
///           child: ListView.builder(
///             controller: scrollManager['list1'],
///             itemBuilder: (context, index) => Text('Item $index'),
///           ),
///         ),
///         Expanded(
///           child: ListView.builder(
///             controller: scrollManager['list2'],
///             itemBuilder: (context, index) => Text('Item $index'),
///           ),
///         ),
///       ],
///     );
///   },
/// )
/// ```
class PostFrameScrollBuilder extends StatefulWidget {
  /// List of controller keys to create automatically.
  ///
  /// Each key will have a [ScrollController] created for it.
  final List<String> controllerKeys;

  /// Map of controller keys to their initial scroll offsets.
  ///
  /// If a key is not in this map, the initial offset will be 0.
  final Map<String, double>? initialScrollOffsets;

  /// Callback invoked after the first frame is rendered.
  ///
  /// Provides [PostFrameScrollData] containing the context, size,
  /// and scroll manager.
  final FutureOr<void> Function(PostFrameScrollData data)? onAfterBuildFrame;

  /// Builder function that provides the scroll manager for building the UI.
  final Widget Function(
    BuildContext context,
    PostFrameScrollManager scrollManager,
  )
  builder;

  /// Optional callback invoked when any scroll controller's position changes.
  ///
  /// The [key] parameter indicates which controller triggered the callback.
  final void Function(String key, double offset)? onScroll;

  const PostFrameScrollBuilder({
    super.key,
    this.controllerKeys = const [],
    this.initialScrollOffsets,
    this.onAfterBuildFrame,
    required this.builder,
    this.onScroll,
  });

  @override
  State<PostFrameScrollBuilder> createState() => _PostFrameScrollBuilderState();
}

class _PostFrameScrollBuilderState extends State<PostFrameScrollBuilder>
    with FlutterPostFrameMixin<PostFrameScrollBuilder> {
  late final PostFrameScrollManager _scrollManager;
  Size? _widgetSize;

  @override
  void initState() {
    super.initState();
    _scrollManager = PostFrameScrollManager();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final key in widget.controllerKeys) {
      final initialOffset = widget.initialScrollOffsets?[key] ?? 0.0;
      _scrollManager.createController(key, initialScrollOffset: initialOffset);

      if (widget.onScroll != null) {
        _scrollManager.addScrollListener(key, () {
          final offset = _scrollManager.getScrollOffset(key);
          if (offset != null) {
            widget.onScroll!(key, offset);
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(PostFrameScrollBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle added/removed controller keys
    final oldKeys = oldWidget.controllerKeys.toSet();
    final newKeys = widget.controllerKeys.toSet();

    // Remove controllers for removed keys
    for (final key in oldKeys.difference(newKeys)) {
      _scrollManager.disposeController(key);
    }

    // Create controllers for new keys
    for (final key in newKeys.difference(oldKeys)) {
      final initialOffset = widget.initialScrollOffsets?[key] ?? 0.0;
      _scrollManager.createController(key, initialScrollOffset: initialOffset);

      if (widget.onScroll != null) {
        _scrollManager.addScrollListener(key, () {
          final offset = _scrollManager.getScrollOffset(key);
          if (offset != null) {
            widget.onScroll!(key, offset);
          }
        });
      }
    }
  }

  @override
  FutureOr<void> onAfterBuildFrame(BuildContext context) async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    _widgetSize = renderBox?.size;

    if (widget.onAfterBuildFrame != null) {
      await widget.onAfterBuildFrame!(
        PostFrameScrollData(
          context: context,
          size: _widgetSize,
          scrollManager: _scrollManager,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _scrollManager);
  }
}

/// A mixin that provides post-frame callback with multiple scroll controller support.
///
/// Use this mixin in a [StatefulWidget] to get access to scroll management
/// after the first frame is rendered.
///
/// Example:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget>
///     with FlutterPostFrameScrollMixin<MyWidget> {
///   @override
///   List<String> get scrollControllerKeys => ['mainList', 'secondaryList'];
///
///   @override
///   FutureOr<void> onAfterBuildFrameWithScroll(PostFrameScrollData data) {
///     // Access scroll controllers and widget info here
///     print('Widget size: ${data.size}');
///     data.scrollManager.animateTo('mainList', 100,
///       duration: Duration(milliseconds: 300));
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ListView(
///       controller: scrollManager['mainList'],
///       children: [...],
///     );
///   }
/// }
/// ```
mixin FlutterPostFrameScrollMixin<T extends StatefulWidget> on State<T> {
  late final PostFrameScrollManager _scrollManager;
  Size? _widgetSize;

  /// Override to provide the list of scroll controller keys to create.
  List<String> get scrollControllerKeys => [];

  /// Override to provide initial scroll offsets for each controller key.
  Map<String, double>? get initialScrollOffsets => null;

  /// The scroll manager for accessing multiple controllers.
  PostFrameScrollManager get scrollManager => _scrollManager;

  /// The size of the widget after the first frame.
  Size? get widgetSize => _widgetSize;

  @override
  void initState() {
    super.initState();
    _scrollManager = PostFrameScrollManager();
    _initializeControllers();

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        _widgetSize = renderBox?.size;

        onAfterBuildFrameWithScroll(
          PostFrameScrollData(
            context: context,
            size: _widgetSize,
            scrollManager: _scrollManager,
          ),
        );
      }
    });
  }

  void _initializeControllers() {
    for (final key in scrollControllerKeys) {
      final initialOffset = initialScrollOffsets?[key] ?? 0.0;
      _scrollManager.createController(key, initialScrollOffset: initialOffset);
    }
  }

  /// Override this method to execute code after the first frame is rendered.
  ///
  /// The [data] parameter provides access to the context, size, and scroll manager.
  FutureOr<void> onAfterBuildFrameWithScroll(PostFrameScrollData data);

  @override
  void dispose() {
    _scrollManager.dispose();
    super.dispose();
  }
}
