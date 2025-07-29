import 'package:flutter/material.dart';

// ... (rest of your existing code)

// New CustomPainter for the bubble effect
class BubblePainter extends CustomPainter {
  final bool isCompleted;
  final bool isLoading;
  final bool isFailed;
  final bool isPending;
  final int stepNumber;
  final double animationValue; // For the pointing effect

  BubblePainter({
    required this.isCompleted,
    required this.isLoading,
    required this.isFailed,
    required this.isPending,
    required this.stepNumber,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Color fillColor;
    Color borderColor;
    Color contentColor; // Color for the checkmark, cross, etc.

    if (isFailed) {
      fillColor = Colors.red;
      borderColor = Colors.red;
      contentColor = Colors.white;
    } else if (isPending) {
      fillColor = Colors.orange;
      borderColor = Colors.orange;
      contentColor = Colors.white;
    } else if (isCompleted) {
      fillColor = Colors.green;
      borderColor = Colors.green;
      contentColor = Colors.white;
    } else {
      fillColor = Colors.grey[200]!;
      borderColor = Colors.grey[300]!;
      contentColor = Colors.grey[600]!;
    }

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path();
    if (isCompleted && !isFailed && !isPending && stepNumber == 1) {
      // Step 1 completed, pointing right
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
      // Add a pointing triangle to the right
      final pointExtension = radius * 0.3 * animationValue; // Animate the extension
      path.moveTo(center.dx + radius - 2, center.dy);
      path.lineTo(center.dx + radius + pointExtension, center.dy - radius * 0.2);
      path.lineTo(center.dx + radius + pointExtension, center.dy + radius * 0.2);
      path.close();
    } else if (isLoading && stepNumber == 2) {
      // Step 2 receiving, pointing left
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
      // Add a pointing triangle to the left
      final pointExtension = radius * 0.3 * animationValue; // Animate the extension
      path.moveTo(center.dx - radius + 2, center.dy);
      path.lineTo(center.dx - radius - pointExtension, center.dy - radius * 0.2);
      path.lineTo(center.dx - radius - pointExtension, center.dy + radius * 0.2);
      path.close();
    } else {
      // Default circular shape
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Draw content (checkmark, number, etc.)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (isLoading && !isFailed && !isPending) {
      // For loading, draw the progress indicator behind the content
      // The CircularProgressIndicator will be drawn in the main widget tree
    } else if (isCompleted && !isFailed && !isPending) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.check.codePoint),
          style: TextStyle(
            fontSize: 30,
            fontFamily: Icons.check.fontFamily,
            color: contentColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
      iconPainter.paint(canvas, Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2));
    } else if (isFailed) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.close.codePoint),
          style: TextStyle(
            fontSize: 30,
            fontFamily: Icons.close.fontFamily,
            color: contentColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
      iconPainter.paint(canvas, Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2));
    } else if (isPending) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.schedule.codePoint),
          style: TextStyle(
            fontSize: 24,
            fontFamily: Icons.schedule.fontFamily,
            color: contentColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
      iconPainter.paint(canvas, Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2));
    } else {
      textPainter.text = TextSpan(
        text: stepNumber.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: contentColor,
        ),
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.isFailed != isFailed ||
        oldDelegate.isPending != isPending ||
        oldDelegate.stepNumber != stepNumber ||
        oldDelegate.animationValue != animationValue;
  }
}

class DropletShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0);
    path.quadraticBezierTo(0, size.height * 0.5, size.width * 0.25, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
