import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_post_frame/flutter_post_frame.dart';
import 'package:flutter_post_frame/post_frame_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Post Frame Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Post Frame Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'PostFrameBuilder Example',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          PostFrameBuilderExample(),
          SizedBox(height: 32),
          Text(
            'FlutterPostFrameMixin Example',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          MixinExample(),
        ],
      ),
    );
  }
}

/// Example 1: Using PostFrameBuilder in a StatelessWidget
/// This is like having initState in a StatelessWidget!
class PostFrameBuilderExample extends StatelessWidget {
  const PostFrameBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PostFrameBuilder(
      onAfterBuildFrame: (context, size) {
        // This callback runs after the first frame is rendered
        // Perfect for getting the widget's actual size
        debugPrint('PostFrameBuilder - Widget size: $size');

        // You can also show dialogs, snackbars, or trigger navigation here
        // ScaffoldMessenger.of(context).showSnackBar(...);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'This widget uses PostFrameBuilder.\n'
          'Check the debug console for the size!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Example 2: Using FlutterPostFrameMixin in a StatefulWidget
/// Override onAfterBuildFrame to execute code after the first frame
class MixinExample extends StatefulWidget {
  const MixinExample({super.key});

  @override
  State<MixinExample> createState() => _MixinExampleState();
}

class _MixinExampleState extends State<MixinExample>
    with FlutterPostFrameMixin<MixinExample> {
  String _status = 'Waiting for first frame...';
  Size? _widgetSize;

  @override
  FutureOr<void> onAfterBuildFrame(BuildContext context) {
    // This runs after the first frame is rendered
    // You have access to the full context and can get the RenderBox
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    setState(() {
      _widgetSize = renderBox?.size;
      _status = 'First frame rendered!';
    });

    debugPrint('FlutterPostFrameMixin - Widget size: $_widgetSize');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: $_status'),
          if (_widgetSize != null)
            Text(
              'Size: ${_widgetSize!.width.toStringAsFixed(1)} x '
              '${_widgetSize!.height.toStringAsFixed(1)}',
            ),
          const SizedBox(height: 8),
          const Text(
            'This widget uses FlutterPostFrameMixin.\n'
            'The mixin overrides onAfterBuildFrame.',
          ),
        ],
      ),
    );
  }
}
