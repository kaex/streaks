import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../models/habit.dart';
import '../utils/icon_utils.dart';
import '../utils/date_utils.dart';
import '../widgets/share_preview.dart';

class ShareUtils {
  /// Create a singleton instance for efficiency
  static final ShareUtils _instance = ShareUtils._internal();
  factory ShareUtils() => _instance;
  ShareUtils._internal();

  /// Cache boundary key for reuse
  final GlobalKey _boundaryKey = GlobalKey();

  /// Captures a widget as an image and returns the bytes
  Future<Uint8List?> _captureWidgetAsImage(Widget widget) async {
    try {
      /// Create a repaint boundary to render the widget
      final RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      /// Capture the image with lower pixel ratio for better performance
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);

      /// Get the bytes with optimized compression
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('Failed to convert image to byte data');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget as image: $e');
      return null;
    }
  }

  /// Creates a temporary file from the image bytes
  Future<File?> _createShareableFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'streaks_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('Error creating shareable file: $e');
      return null;
    }
  }

  /// Renders the widget off-screen and shares it
  Future<void> shareWidget(
    BuildContext context,
    Widget widget, {
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    /// Show loading indicator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Preparing to share...'),
        duration: Duration(seconds: 1),
      ),
    );

    /// Use compute isolate for heavy work if possible
    final imageBytes = await _renderWidget(context, widget);

    if (imageBytes == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to render image for sharing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final file = await _createShareableFile(imageBytes);
    if (file == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to create shareable file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    /// Add haptic feedback for better UX
    HapticFeedback.mediumImpact();

    /// Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<Uint8List?> _renderWidget(BuildContext context, Widget widget) async {
    /// Create an overlay to render the widget off-screen
    final overlayState = Overlay.of(context);
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Rect bounds = Rect.fromPoints(
      box.localToGlobal(Offset.zero),
      box.localToGlobal(box.size.bottomRight(Offset.zero)),
    );

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: bounds.left,
        top: bounds.top,
        width: box.size.width,
        height: box.size.height,
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: widget,
          ),
        ),
      ),
    );

    /// Insert the widget into the overlay
    overlayState.insert(entry);

    /// Allow the widget to render
    await Future.delayed(const Duration(milliseconds: 20));

    /// Capture the image
    final imageBytes = await _captureWidgetAsImage(widget);

    /// Remove the overlay
    entry.remove();

    return imageBytes;
  }

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
    // Create the widget to share
    final sharePreview = CustomSharePreview(
      habit: habit,
      themeIsDark: themeIsDark,
      customColor: customColor,
      showCompletionIndicator: showCompletionIndicator,
      showDescription: showDescription,
      showStreak: showStreak,
    );

    // Reuse the instance method to share the widget
    await ShareUtils().shareWidget(
      context,
      sharePreview,
      text: '${habit.title} - Tracked with Streaks',
    );
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

// Add a new widget specifically for sharing without buttons
class CustomSharePreview extends StatelessWidget {
  final Habit habit;
  final bool themeIsDark;
  final Color? customColor;
  final bool showCompletionIndicator;
  final bool showDescription;
  final bool showStreak;

  const CustomSharePreview({
    super.key,
    required this.habit,
    this.themeIsDark = true,
    this.customColor,
    this.showCompletionIndicator = true,
    this.showDescription = true,
    this.showStreak = true,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final rows = 7;
    final cols = 20;
    final habitColor = customColor ?? habit.color;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeIsDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeIsDark ? Colors.grey[900]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                'STREAKS',
                style: TextStyle(
                  color: themeIsDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),

          // Habit info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconUtils.getIconData(habit.iconName),
                  color: habitColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        color: themeIsDark ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showDescription && habit.description.isNotEmpty)
                      Text(
                        habit.description,
                        style: TextStyle(
                          color:
                              themeIsDark ? Colors.grey[400] : Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Streak visualization (mini version)
          if (showCompletionIndicator)
            AspectRatio(
              aspectRatio: 1.5,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20, // 20 columns
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final dayOffset = (rows * cols) - 1 - index;
                  final date =
                      DateTime(today.year, today.month, today.day - dayOffset);

                  final isCompleted = habit.completionDates[date] == true;
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? habitColor.withOpacity(0.7)
                          : habitColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: habitColor,
                              width: 1,
                            )
                          : null,
                    ),
                    child: isCompleted
                        ? Center(
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color:
                                    themeIsDark ? Colors.white : Colors.black87,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          // Stats
          if (showStreak)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                    'Duration', '${_formatDuration(habit)}', themeIsDark),
                _buildStatColumn(
                    'Streak', '${habit.currentStreak}', themeIsDark),
                _buildStatColumn(
                    'Total', '${habit.totalCompletions}', themeIsDark),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, bool isDark) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Habit habit) {
    final startDate = habit.startDate;
    final now = DateTime.now();
    final difference = now.difference(startDate);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return '1 day';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
  }
}
