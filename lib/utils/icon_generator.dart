import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class IconGenerator {
  static Future<void> generateAppIcon() async {
    // Create a key to identify the widget
    final GlobalKey key = GlobalKey();

    // Create a widget with the app icon design
    final iconWidget = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: key,
        child: Container(
          width: 1024,
          height: 1024,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF121212), Color(0xFF2A2A2A)],
            ),
            borderRadius: BorderRadius.circular(240),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.whatshot_rounded,
                  size: 450,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 600,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red[400]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      10,
                      (index) => Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: index < 6 ? Colors.red[400] : Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Render the widget to a PNG
    await renderIcon(key, iconWidget);
  }

  static Future<void> renderIcon(GlobalKey key, Widget iconWidget) async {
    // Create a temporary directory to render the widget
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // Create a render object
    final renderObject = RenderRepaintBoundary();

    // Create a pipeline owner
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    // Create a building context
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderObject,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: iconWidget,
      ),
    ).attachToRenderTree(buildOwner);

    // Layout the widget
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.rootNode = renderObject;
    renderObject.layout(const BoxConstraints(maxWidth: 1024, maxHeight: 1024));

    // Layout pass
    final constraints = const BoxConstraints(
      maxWidth: 1024,
      maxHeight: 1024,
    );
    renderObject.layout(constraints);

    // Composite pass
    final image = await renderObject.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();

      // Save to assets directory
      final appDir = Directory('assets/icon');
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      final file = File('${appDir.path}/app_icon.png');
      await file.writeAsBytes(pngBytes);

      print('Icon generated: ${file.path}');
    } else {
      print('Failed to generate icon');
    }
  }
}
