# flutter_post_frame

A lightweight Flutter package that provides utilities to execute callbacks after the first frame is rendered. Perfect for getting widget sizes, managing multiple scroll controllers, or performing post-build operations.

## Example

![Example Demo](assets/video/example.gif)

## Features

- **FlutterPostFrameMixin**: A mixin for `StatefulWidget` states that calls `onAfterBuildFrame()` after the first frame is rendered.
- **PostFrameBuilder**: A widget wrapper that provides a callback with the `BuildContext` and rendered widget's `Size` after the first frame.
- **PostFrameScrollBuilder**: A widget that manages multiple `ScrollController`s with post-frame callbacks.
- **FlutterPostFrameScrollMixin**: A mixin for managing multiple scroll controllers with post-frame callbacks.
- **PostFrameScrollManager**: A utility class for creating and managing multiple named scroll controllers.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_post_frame: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Using FlutterPostFrameMixin

Add the mixin to your `State` class to execute code after the first frame:

```dart
import 'package:flutter_post_frame/flutter_post_frame.dart';

class MyWidgetState extends State<MyWidget> with FlutterPostFrameMixin<MyWidget> {
  @override
  FutureOr<void> onAfterBuildFrame(BuildContext context) {
    // This runs after the first frame is rendered
    print('Widget has been rendered!');
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Using PostFrameBuilder

Wrap your widget with `PostFrameBuilder` to get the widget's size after rendering:

```dart
import 'package:flutter_post_frame/post_frame_builder.dart';

PostFrameBuilder(
  onAfterBuildFrame: (context, size) {
    print('Widget size: $size');
  },
  child: Container(
    width: 200,
    height: 100,
    color: Colors.blue,
  ),
)
```

### initState-like behavior in StatelessWidget

Use `PostFrameBuilder` to execute one-time initialization logic in a `StatelessWidget`, similar to `initState` in `StatefulWidget`:

```dart
import 'package:flutter_post_frame/post_frame_builder.dart';

class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostFrameBuilder(
      onAfterBuildFrame: (context, size) {
        // This runs once after the first frame - like initState!
        // Perfect for:
        // - Showing a dialog or snackbar
        // - Triggering navigation
        // - Fetching data based on widget size
        // - Starting animations
        print('Widget initialized with size: $size');
      },
      child: YourContentWidget(),
    );
  }
}
```

This is especially useful when you want to keep your widget stateless but still need to perform post-build operations.

### Using PostFrameScrollBuilder (Multiple ScrollControllers)

Manage multiple scroll controllers with ease:

```dart
import 'package:flutter_post_frame/flutter_post_frame.dart';

PostFrameScrollBuilder(
  controllerKeys: ['list1', 'list2', 'list3'],
  initialScrollOffsets: {'list1': 100.0}, // Optional initial offsets
  onAfterBuildFrame: (data) {
    // Access BuildContext, Size, and scroll manager
    print('Widget size: ${data.size}');
    print('Controllers: ${data.scrollManager.keys}');
    
    // Scroll to a position after build
    data.scrollManager.animateTo(
      'list1',
      200,
      duration: Duration(milliseconds: 300),
    );
  },
  onScroll: (key, offset) {
    // Track scroll position changes for any controller
    print('$key scrolled to: $offset');
  },
  builder: (context, scrollManager) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollManager['list1'],
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollManager['list2'],
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ],
    );
  },
)
```

### Using FlutterPostFrameScrollMixin

For full control in StatefulWidgets:

```dart
import 'package:flutter_post_frame/flutter_post_frame.dart';

class MyWidgetState extends State<MyWidget> 
    with FlutterPostFrameScrollMixin<MyWidget> {
  
  @override
  List<String> get scrollControllerKeys => ['mainList', 'sidebar'];
  
  @override
  Map<String, double>? get initialScrollOffsets => {'mainList': 50.0};

  @override
  FutureOr<void> onAfterBuildFrameWithScroll(PostFrameScrollData data) {
    // Access BuildContext, Size, and scroll manager
    print('Widget size: ${data.size}');
    
    // Add scroll listeners
    scrollManager.addScrollListener('mainList', () {
      print('Scroll offset: ${scrollManager.getScrollOffset('mainList')}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView(
            controller: scrollManager['mainList'],
            children: [...],
          ),
        ),
        SizedBox(
          width: 200,
          child: ListView(
            controller: scrollManager['sidebar'],
            children: [...],
          ),
        ),
      ],
    );
  }
}
```

### PostFrameScrollManager API

The `PostFrameScrollManager` class provides these methods:

```dart
final manager = PostFrameScrollManager();

// Create controllers
manager.createController('key', initialScrollOffset: 0.0);

// Access controllers
final controller = manager['key'];  // Or manager.getController('key')

// Scroll operations
manager.animateTo('key', 100, duration: Duration(ms: 300));
manager.jumpTo('key', 100);
manager.scrollToTop('key');
manager.scrollToBottom('key');

// Get scroll information
manager.getScrollOffset('key');
manager.getMaxScrollExtent('key');
manager.getMinScrollExtent('key');

// Listeners
manager.addScrollListener('key', callback);
manager.removeScrollListener('key', callback);

// Cleanup
manager.disposeController('key');
manager.dispose();  // Dispose all
```

## Supported Platforms

| Android | iOS | Linux | macOS | Web | Windows |
|:-------:|:---:|:-----:|:-----:|:---:|:-------:|
|    ✅    |  ✅  |   ✅   |   ✅   |  ✅  |    ✅    |

## Additional information

This package uses `WidgetsBinding.instance.endOfFrame` to ensure callbacks are executed after the widget tree has been fully rendered. This is particularly useful when you need to:

- Get the actual rendered size of a widget
- Perform navigation or show dialogs after the initial build
- Execute animations or scroll operations that depend on layout completion

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

- [Repository](https://github.com/sujithsdeveloper/flutter_post_frame)
- [Issue Tracker](https://github.com/sujithsdeveloper/flutter_post_frame/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
