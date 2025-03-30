import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/habit.dart';
import '../utils/icon_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/share_preview.dart';

class ShareUtils {
  /// Shares habit summary as an image
  static Future<void> shareHabitSummary(
    BuildContext context,
    Habit habit, {
    bool themeIsDark = true,
    Color? customColor,
    bool showCompletionIndicator = true,
    bool showDescription = true,
    bool showStreak = true,
  }) async {
    // Show loading indicator
    try {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Generating image...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Create a key to identify the repaint boundary
      final RenderRepaintBoundary boundary = await _generateHabitSummaryImage(
        context,
        habit,
        themeIsDark: themeIsDark,
        customColor: customColor,
        showCompletionIndicator: showCompletionIndicator,
        showDescription: showDescription,
        showStreak: showStreak,
      );

      // Convert boundary to image with lower pixel ratio to reduce memory usage
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/streak_share.png');
        await file.writeAsBytes(pngBytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my streak for ${habit.title}!',
        );
      }
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  /// Directly shares text without preview or image generation
  static Future<void> directShareText(BuildContext context, Habit habit) async {
    try {
      shareHabitText(context, habit);
    } catch (e) {
      print('Failed to share text directly: $e');
      _showErrorSnackbar(context);
    }
  }

  static Future<void> _executeShare(BuildContext context, Habit habit) async {
    try {
      await _generateAndShareImage(context, habit);
    } catch (e) {
      print('Error in executeShare: $e');
      // Fall back to simple text sharing if image sharing fails
      shareHabitText(context, habit);
    }
  }

  static Future<void> _generateAndShareImage(
      BuildContext context, Habit habit) async {
    // Show loading indicator
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Generating image...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Create a key to identify the repaint boundary
      final RenderRepaintBoundary boundary =
          await _generateHabitSummaryImage(context, habit);

      // Convert boundary to image with lower pixel ratio to reduce memory usage
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/streak_share.png');
        await file.writeAsBytes(pngBytes);

        // Share the file
        try {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Check out my streak for ${habit.title}!',
          );
        } catch (e) {
          print('Error sharing image: $e');
          // Fall back to text sharing
          shareHabitText(context, habit);
        }
      } else {
        shareHabitText(context, habit);
      }
    } catch (e) {
      print('Error generating image: $e');
      shareHabitText(context, habit);
    }
  }

  /// Share habit information as plain text
  static Future<void> shareHabitText(BuildContext context, Habit habit) async {
    final currentStreak = habit.currentStreak;
    final totalCompletions = habit.totalCompletions;

    String shareText =
        'I\'ve been keeping up with "${habit.title}" for ${currentStreak} days in a row! 🔥\n'
        'Total completions: ${totalCompletions}\n'
        'Tracking my habits with Streaks app';

    try {
      await Share.share(shareText);
    } catch (e) {
      print('Error sharing text: $e');
      _showErrorSnackbar(context);
    }
  }

  static void _showErrorSnackbar(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Failed to share. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Future<RenderRepaintBoundary> _generateHabitSummaryImage(
    BuildContext context,
    Habit habit, {
    bool themeIsDark = true,
    Color? customColor,
    bool showCompletionIndicator = true,
    bool showDescription = true,
    bool showStreak = true,
  }) async {
    // Use the customColor or fall back to the habit's color
    final color = customColor ?? habit.color;

    // Create a GlobalKey for the RepaintBoundary
    final globalKey = GlobalKey();

    // Create a Completer to resolve when rendering is done
    final completer = Completer<RenderRepaintBoundary>();

    // Build the widget tree off-screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Once the frame is built, we can get the RenderObject
      final RenderRepaintBoundary? boundary = globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        completer.complete(boundary);
      } else {
        completer.completeError('Could not find RenderRepaintBoundary');
      }
    });

    // Use a smaller size for the image to reduce memory usage
    final width = 810; // 75% of original 1080
    final height = 1440; // 75% of original 1920

    // Insert the widget into the widget tree briefly to render it
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: -9999, // Position off-screen
          top: -9999,
          child: RepaintBoundary(
            key: globalKey,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width.toDouble(),
                height: height.toDouble(),
                color: color, // Use habit color as background
                padding: const EdgeInsets.all(30), // Reduced padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(20), // Smaller radius
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, // Reduced padding
                        vertical: 30, // Reduced padding
                      ),
                      child: Column(
                        children: [
                          // Habit info with icon, title and description
                          Row(
                            children: [
                              // Icon container
                              Container(
                                height: 80, // Smaller size
                                width: 80, // Smaller size
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                      20), // Smaller radius
                                ),
                                child: Icon(
                                  IconUtils.getIconData(habit.iconName),
                                  color: Colors.white,
                                  size: 48, // Smaller icon
                                ),
                              ),
                              const SizedBox(width: 20), // Smaller spacing
                              // Habit details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (showDescription &&
                                        habit.description.isNotEmpty)
                                      Text(
                                        habit.description,
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Completion icon
                              if (showCompletionIndicator)
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: color,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),

                          // Streak Grid
                          if (showStreak) const SizedBox(height: 40),

                          if (showStreak)
                            Container(
                              height: 240,
                              child: _buildShareStreakGrid(habit, color),
                            ),
                        ],
                      ),
                    ),

                    // HabitKit branding
                    Padding(
                      padding: const EdgeInsets.only(top: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Streaks - Habit Tracker',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Add to overlay and wait for rendering
    overlayState.insert(overlayEntry);
    final boundary = await completer.future;
    overlayEntry.remove();

    return boundary;
  }

  // Build a streak grid similar to HabitKit for sharing
  static Widget _buildShareStreakGrid(Habit habit, Color color) {
    final rows = 7;
    final cols = 25;
    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 25,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final dayOffset = (rows * cols) - 1 - index;
        final date = DateTime(today.year, today.month, today.day - dayOffset);
        final isCompleted = habit.completionDates[date] == true;

        return Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: isCompleted
              ? Center(
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
