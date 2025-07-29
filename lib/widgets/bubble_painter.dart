import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  final bool isCompleted;
  final bool isLoading;
  final bool isFailed;
  final bool isPending;
  final int stepNumber;
  final double animationValue;

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
    Color contentColor;

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
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
      final pointExtension = radius * 0.3 * animationValue;

      path.moveTo(center.dx + radius - 2, center.dy);
      path.lineTo(center.dx + radius + pointExtension, center.dy - radius * 0.2);
      path.lineTo(center.dx + radius + pointExtension, center.dy + radius * 0.2);
      path.close();
    } else if (isLoading && stepNumber == 2) {
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
      final pointExtension = radius * 0.3 * animationValue;
      path.moveTo(center.dx - radius + 2, center.dy);
      path.lineTo(center.dx - radius - pointExtension, center.dy - radius * 0.2);
      path.lineTo(center.dx - radius - pointExtension, center.dy + radius * 0.2);
      path.close();
    } else {
      path.addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: center, radius: radius), Radius.circular(radius)));
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (isLoading && !isFailed && !isPending) {
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

