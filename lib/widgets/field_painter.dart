import 'package:flutter/material.dart';

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    final dot = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), line);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.16, line);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, dot);
    canvas.drawRect(Rect.fromLTWH(size.width * .25, 0, size.width * .5, size.height * .14), line);
    canvas.drawRect(Rect.fromLTWH(size.width * .36, 0, size.width * .28, size.height * .07), line);
    canvas.drawRect(Rect.fromLTWH(size.width * .25, size.height * .86, size.width * .5, size.height * .14), line);
    canvas.drawRect(Rect.fromLTWH(size.width * .36, size.height * .93, size.width * .28, size.height * .07), line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
