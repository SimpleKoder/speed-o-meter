import 'dart:math';

import 'package:flutter/material.dart';

class SpeedMeter extends StatefulWidget {
  const SpeedMeter({super.key});

  @override
  State<SpeedMeter> createState() => _SpeedMeterState();
}

class _SpeedMeterState extends State<SpeedMeter>
    with SingleTickerProviderStateMixin {
  late Animation<double> anim;
  late AnimationController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    anim = Tween<double>(begin: 0, end: 72).animate(ctrl);
    ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Speed Meter"),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).width,
          child: AnimatedBuilder(
            builder: (context, child) {
              return CustomPaint(
                painter: MeterPainter(anim.value),
              );
            },
            animation: ctrl,
          ),
        ),
      ),
    );
  }
}

class MeterPainter extends CustomPainter {
  final double percent;

  MeterPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final centerY = h / 2;

    final center = Offset(centerX, centerY);
    final rect =
        Rect.fromCenter(center: center, width: w * 0.7, height: h * 0.7);
    final largeRect =
        Rect.fromCenter(center: center, width: w * 0.75, height: h * 0.75);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey;

    final thickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.grey.shade900;
    final startAngle = angleToRadian(135);
    final sweepAngle = angleToRadian(270);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    canvas.drawArc(largeRect, startAngle, sweepAngle, false, thickPaint);

    final pointedSweeepAngle = angleToRadian(270 * percent / 100);

    canvas.drawArc(largeRect, startAngle, pointedSweeepAngle, false,
        thickPaint..color = Colors.pink);

    final radius = w / 2;

    for (num angle = 135; angle <= 405; angle += 4.5) {
      final start = angleToOffset(center, angle, radius * 0.7);
      final end = angleToOffset(center, angle, radius * 0.65);
      canvas.drawLine(start, end, paint);
    }

    final highlights = List.generate(11, (index) => 135 + (27 * index));
    for (int i = 0; i < highlights.length; i++) {
      var angle = highlights[i];
      final start = angleToOffset(center, angle, radius * 0.7);
      final end = angleToOffset(center, angle, radius * 0.575);
      canvas.drawLine(start, end, paint);

      final tp = TextPainter(
          text: TextSpan(text: "${i * 10}"), textDirection: TextDirection.ltr);
      tp.layout();
      final textOffset = angleToOffset(center, angle, radius * 0.5);
      final centered =
          Offset(textOffset.dx - tp.width / 2, textOffset.dy - tp.height / 2);
      tp.paint(canvas, centered);
    }

    final tp = TextPainter(
        text: TextSpan(
            text: "${percent.toInt()}",
            style: TextStyle(fontSize: 60),
            children: [
              TextSpan(
                text: "\nkm/h",
                style: TextStyle(fontSize: 30),
              )
            ]),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    final centered =
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2);
    tp.paint(canvas, centered);
  }

  Offset angleToOffset(Offset center, num angle, double distance) {
    final radian = angleToRadian(angle);
    final x = center.dx + distance * cos(radian);
    final y = center.dx + distance * sin(radian);
    return Offset(x, y);
  }

  double angleToRadian(num angle) {
    return angle * pi / 180;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
