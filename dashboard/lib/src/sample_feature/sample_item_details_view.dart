import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:dashboard/src/sample_feature/sample_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';

import 'dart:ui' as ui;

import 'package:rxdart/rxdart.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';
  BehaviorSubject<List<Offset>> points = BehaviorSubject.seeded([]);
  BehaviorSubject<bool> alarm = BehaviorSubject.seeded(false);

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  @override
  void initState() {
    super.initState();
    // Start the timer to toggle the image display
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          RenderBox renderBox = context.findRenderObject() as RenderBox;

          widget.points.value = widget.points.value
            ..add(renderBox.globalToLocal(details.globalPosition));

          bool checkFormAlarm() {
            final points = widget.points.value;
            final boundingBoxes = args["boundingBoxes"];
            for (var i = 0; i < points.length; i++) {
              for (var j = 0; j < boundingBoxes.length; j++) {
                final point = points[i];
                final boundingBox = boundingBoxes[j];
                final x = boundingBox["x"]! as double;
                final y = boundingBox["y"]! as double;
                final xPlusWidth = x + boundingBox["width"]!;
                final yPlusHeight = y + boundingBox["height"]!;
                if (Rectangle.fromPoints(
                        Point(x, y), Point(xPlusWidth, yPlusHeight))
                    .containsPoint(Point(point.dx, point.dy))) {
                  return true;
                }
              }
            }
            return false;
          }

          widget.alarm.value = checkFormAlarm();
        },
        child: FutureBuilder<Uint8List>(
          future: fetchImage(args["url"]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Stack(
                children: [
                  Image.memory(snapshot.data!),
                  StreamBuilder<Object>(
                      stream: widget.points,
                      builder: (context, snapshot) {
                        return CustomPaint(
                          painter: LinePainter(
                              points: widget.points.value,
                              boundingBoxes: args["boundingBoxes"]),
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: widget.alarm,
                      builder: (context, snapshot) {
                        if (widget.alarm.value) {
                          return Text(
                            " ALARM",
                            style: TextStyle(
                              fontSize: 100.0, // Adjust as needed
                              color: Colors.red,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      })
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

Future<Uint8List> fetchImage(String url) async {
  final response = await get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}

class LinePainter extends CustomPainter {
  LinePainter({required this.points, required this.boundingBoxes});
  final List<Offset> points;

  final List<Map<String, double>> boundingBoxes;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1],
          Paint()..color = Color.fromARGB(255, 255, 0, 0));
    }

    for (var i = 0; i < boundingBoxes.length; i++) {
      final boundingBox = boundingBoxes[i];
      final rect = Rect.fromLTWH(boundingBox["x"]!, boundingBox["y"]!,
          boundingBox["width"]!, boundingBox["height"]!);
      canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Color.fromARGB(255, 255, 0, 0));
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(LinePainter oldDelegate) => false;
}
