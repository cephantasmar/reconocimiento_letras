import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

import 'blocs/drawing/drawing_bloc.dart';

class DrawingPage extends StatelessWidget {
  final List<List<int>> drawingPoints = []; // Lista de puntos de dibujo (para la predicción)

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DrawingBloc()..loadModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dibuja una Letra'),
        ),
        body: BlocBuilder<DrawingBloc, DrawingState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: DrawingCanvas(drawingPoints) ),
                ElevatedButton(
                  onPressed: () {
                    print("se presionó");
                    BlocProvider.of<DrawingBloc>(context).add(PredictLetter(drawingPoints));
                  },
                  child: Text('Predecir Letra'),
                ),
                ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<DrawingBloc>(context).add(ClearCanvas());
                    drawingPoints.clear(); // Limpiar la lista de puntos
                  },
                  child: Text('Limpiar Pizarra'),
                ),
                if (state is PredictionLoading) CircularProgressIndicator(),
                if (state is PredictionSuccess)
                  Text('Letra Predicha: ${state.predictedLetter}'),
                if (state is PredictionError) Text('Error en la predicción'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DrawingCanvas extends StatelessWidget {
  final List<List<int>> drawingPoints;

  DrawingCanvas(this.drawingPoints);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Añadir puntos a la lista mientras el usuario dibuja
        drawingPoints.add([details.localPosition.dx.toInt(), details.localPosition.dy.toInt()]);
        // Refrescar la interfaz para que el dibujo se vea al instante
        (context as Element).reassemble();
      },
      onPanEnd: (details) {
        // Procesar la imagen cuando termine el dibujo (esto lo podrías manejar aquí también)
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: CanvasPainter(drawingPoints),
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  final List<List<int>> drawingPoints;

  CanvasPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 50.0;

    // Dibujar los puntos de dibujo
    for (var point in drawingPoints) {
      canvas.drawCircle(Offset(point[0].toDouble(), point[1].toDouble()), 5, paint);
    }

    // Dibujar el marco de la pizarra (con un margen de 10)
    paint.color = Colors.blue;
    paint.strokeWidth = 3.0;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), paint); // Borde alrededor de la pizarra
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
