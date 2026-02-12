import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_post_frame/flutter_post_frame.dart';

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
          SizedBox(height: 32),
          Text(
            'Multiple ScrollControllers Example',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          MultipleScrollControllersExample(),
          SizedBox(height: 32),
          Text(
            'ScrollMixin Example',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ScrollMixinExample(),
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

/// Example 3: Using PostFrameScrollBuilder to manage multiple ScrollControllers
/// Perfect for coordinating multiple scrollable areas!
class MultipleScrollControllersExample extends StatelessWidget {
  const MultipleScrollControllersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PostFrameScrollBuilder(
        controllerKeys: const ['list1', 'list2'],
        onAfterBuildFrame: (data) {
          debugPrint('PostFrameScrollBuilder - Widget size: ${data.size}');
          debugPrint(
            'Controllers created: ${data.scrollManager.keys.toList()}',
          );
        },
        onScroll: (key, offset) {
          debugPrint('Scroll on $key: $offset');
        },
        builder: (context, scrollManager) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Two synchronized lists with scroll tracking:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => scrollManager.scrollToTop('list1'),
                        child: const Text('List 1 Top'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => scrollManager.scrollToBottom('list1'),
                        child: const Text('List 1 Bottom'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => scrollManager.scrollToTop('list2'),
                        child: const Text('List 2 Top'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            controller: scrollManager['list1'],
                            itemCount: 20,
                            itemBuilder: (context, index) => ListTile(
                              dense: true,
                              title: Text('List 1 - Item $index'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            controller: scrollManager['list2'],
                            itemCount: 20,
                            itemBuilder: (context, index) => ListTile(
                              dense: true,
                              title: Text('List 2 - Item $index'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example 4: Using FlutterPostFrameScrollMixin for full control
class ScrollMixinExample extends StatefulWidget {
  const ScrollMixinExample({super.key});

  @override
  State<ScrollMixinExample> createState() => _ScrollMixinExampleState();
}

class _ScrollMixinExampleState extends State<ScrollMixinExample>
    with FlutterPostFrameScrollMixin<ScrollMixinExample> {
  String _status = 'Waiting for first frame...';
  double _scrollOffset = 0;

  @override
  List<String> get scrollControllerKeys => ['mainScroll'];

  @override
  FutureOr<void> onAfterBuildFrameWithScroll(PostFrameScrollData data) {
    setState(() {
      _status = 'Ready! Size: ${data.size}';
    });

    // Add scroll listener after build
    scrollManager.addScrollListener('mainScroll', () {
      final offset = scrollManager.getScrollOffset('mainScroll');
      if (offset != null && mounted) {
        setState(() => _scrollOffset = offset);
      }
    });

    debugPrint('FlutterPostFrameScrollMixin - Widget size: ${data.size}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: $_status'),
          Text('Scroll offset: ${_scrollOffset.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => scrollManager.scrollToTop('mainScroll'),
                child: const Text('Scroll Top'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => scrollManager.animateTo(
                  'mainScroll',
                  100,
                  duration: const Duration(milliseconds: 500),
                ),
                child: const Text('Scroll to 100'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                controller: scrollManager['mainScroll'],
                itemCount: 30,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  title: Text('Mixin Example - Item $index'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
