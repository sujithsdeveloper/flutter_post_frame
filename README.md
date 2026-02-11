# flutter_post_frame

A lightweight Flutter package that provides utilities to execute callbacks after the first frame is rendered. Perfect for getting widget sizes or performing post-build operations.

## Features

- **FlutterPostFrameMixin**: A mixin for `StatefulWidget` states that calls `onAfterBuildFrame()` after the first frame is rendered.
- **PostFrameBuilder**: A widget wrapper that provides a callback with the `BuildContext` and rendered widget's `Size` after the first frame.

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
