import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/daily_guidance_model.dart';

/// Builds a shareable image card from a guidance item
/// Uses dart:ui Canvas painting directly - no widget tree or overlay needed
class ShareCardBuilder {
  static bool _isSharing = false;

  /// Share a guidance item as an image
  static Future<void> shareItem(
    BuildContext context,
    DailyGuidanceItem item,
    int dayNumber,
  ) async {
    if (_isSharing) return;
    _isSharing = true;

    try {
      final imageBytes = await _renderCard(item, dayNumber);

      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/daily_guidance_day${dayNumber}_${item.type.name}.png',
        );
        await file.writeAsBytes(imageBytes);

        // On iPad, sharePositionOrigin is needed
        final box = context.findRenderObject() as RenderBox?;
        final rect = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: _buildShareText(item, dayNumber),
          sharePositionOrigin: rect,
        );
      } else {
        await _shareAsText(item, dayNumber);
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
      await _shareAsText(item, dayNumber);
    } finally {
      _isSharing = false;
    }
  }

  /// Render the share card entirely via dart:ui Canvas
  static Future<List<int>?> _renderCard(
    DailyGuidanceItem item,
    int dayNumber,
  ) async {
    const double width = 1080;
    const double padding = 80;
    const double contentWidth = width - padding * 2;

    final gradient = _getGradientColors(item.type);

    // Pre-layout all text to calculate total height
    final typeText = _layoutText(
      item.type.label.toUpperCase(),
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.7),
      maxWidth: contentWidth * 0.6,
      letterSpacing: 4,
    );

    final dayText = _layoutText(
      'Day $dayNumber',
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.6),
      maxWidth: contentWidth * 0.4,
    );

    TextPainter? arabicPainter;
    if (item.arabicText.isNotEmpty) {
      arabicPainter = _layoutText(
        item.arabicText,
        fontSize: 64,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        maxWidth: contentWidth,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        height: 1.8,
      );
    }

    final translationPainter = _layoutText(
      item.translation,
      fontSize: item.arabicText.isEmpty ? 52 : 40,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.92),
      maxWidth: contentWidth,
      textAlign: TextAlign.center,
      height: 1.7,
    );

    final refPainter = _layoutText(
      '- ${item.reference}',
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.5),
      maxWidth: contentWidth,
      textAlign: TextAlign.center,
    );

    final brandPainter = _layoutText(
      'Rushd - Daily Guidance',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.5),
      maxWidth: contentWidth,
      textAlign: TextAlign.center,
      letterSpacing: 2,
    );

    // Calculate total height
    double totalHeight = padding; // top padding
    totalHeight += typeText.height + 70; // header + gap
    if (arabicPainter != null) {
      totalHeight += arabicPainter.height + 50; // arabic + gap
      totalHeight += 6 + 40; // divider + gap
    }
    totalHeight += translationPainter.height + 50; // translation + gap
    totalHeight += refPainter.height + 60; // reference + gap
    totalHeight += brandPainter.height + 30 + padding; // brand + brand padding + bottom padding

    // Create canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, totalHeight);

    // Draw gradient background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        gradient,
      );
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(48));
    canvas.drawRRect(rrect, bgPaint);

    double y = padding;

    // Draw header row
    typeText.paint(canvas, Offset(padding, y));
    dayText.paint(
      canvas,
      Offset(size.width - padding - dayText.width, y),
    );
    y += typeText.height + 70;

    // Draw Arabic text
    if (arabicPainter != null) {
      final arabicX = (size.width - arabicPainter.width) / 2;
      arabicPainter.paint(canvas, Offset(arabicX, y));
      y += arabicPainter.height + 50;

      // Divider line
      final dividerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width / 2 - 50, y),
        Offset(size.width / 2 + 50, y),
        dividerPaint,
      );
      y += 6 + 40;
    }

    // Draw translation
    final transX = (size.width - translationPainter.width) / 2;
    translationPainter.paint(canvas, Offset(transX, y));
    y += translationPainter.height + 50;

    // Draw reference
    final refX = (size.width - refPainter.width) / 2;
    refPainter.paint(canvas, Offset(refX, y));
    y += refPainter.height + 60;

    // Draw brand badge background
    final brandBgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, y + brandPainter.height / 2),
        width: brandPainter.width + 40,
        height: brandPainter.height + 20,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(
      brandBgRect,
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
    final brandX = (size.width - brandPainter.width) / 2;
    brandPainter.paint(canvas, Offset(brandX, y));

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  static TextPainter _layoutText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double maxWidth,
    TextAlign textAlign = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
        ),
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: 20,
    );
    painter.layout(maxWidth: maxWidth);
    return painter;
  }

  static List<Color> _getGradientColors(DailyGuidanceType type) {
    switch (type) {
      case DailyGuidanceType.ayah:
        return [const Color(0xFF1A4A3A), const Color(0xFF0D6B4F)];
      case DailyGuidanceType.hadith:
        return [const Color(0xFF2C3E50), const Color(0xFF34495E)];
      case DailyGuidanceType.dua:
        return [const Color(0xFF1A3A5C), const Color(0xFF2D5A7A)];
      case DailyGuidanceType.dhikr:
        return [const Color(0xFF3D2B56), const Color(0xFF5B3A7A)];
      case DailyGuidanceType.reflection:
        return [const Color(0xFF4A3728), const Color(0xFF6B5240)];
      case DailyGuidanceType.dailyDeed:
        return [const Color(0xFF8B6914), const Color(0xFFA68B3D)];
    }
  }

  static Future<void> _shareAsText(
    DailyGuidanceItem item,
    int dayNumber,
  ) async {
    try {
      await Share.share(_buildShareText(item, dayNumber));
    } catch (e) {
      debugPrint('Error sharing text: $e');
    }
  }

  static String _buildShareText(DailyGuidanceItem item, int dayNumber) {
    final buffer = StringBuffer();
    buffer.writeln('Daily Guidance - Day $dayNumber');
    buffer.writeln(item.type.label);
    buffer.writeln();
    if (item.arabicText.isNotEmpty) {
      buffer.writeln(item.arabicText);
      buffer.writeln();
    }
    buffer.writeln(item.translation);
    buffer.writeln();
    buffer.writeln('- ${item.reference}');
    buffer.writeln();
    buffer.write('Shared from Rushd App');
    return buffer.toString();
  }
}
