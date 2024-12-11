import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:object_recognition_app/labels.dart';

class ObjectRecognitionScreen extends StatefulWidget {
  const ObjectRecognitionScreen({Key? key}) : super(key: key);

  @override
  _ObjectRecognitionScreenState createState() =>
      _ObjectRecognitionScreenState();
}

class _ObjectRecognitionScreenState extends State<ObjectRecognitionScreen> {
  late Interpreter _interpreter;
  late List<String> _labels;
  List<Offset?> _points = [];
  String _prediction = '';

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      // Cargar el modelo desde los assets
      _interpreter = await Interpreter.fromAsset('assets/modelo2.tflite');
      print('Modelo cargado exitosamente');

      // Cargar las etiquetas desde el archivo 'labels.txt'

      _labels = label;
      print('Etiquetas cargadas: $_labels');
    } catch (e) {
      print('Error al cargar el modelo o las etiquetas: $e');
    }
  }
  // Dibujar la letra en pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ReconocerIA')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Añadir el punto donde el usuario está tocando
                  _points.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                // Cuando se suelta el dedo, podemos añadir un punto nulo
                _points.add(null);
              },
              child: CustomPaint(
                size: Size(256, 256),
                painter: DrawingPainter(_points),
              ),
            ),
            ElevatedButton(
              onPressed: _predict, // Predicción cuando se presione el botón
              child: const Text('Realizar Predicción'),
            ),
            if (_prediction.isNotEmpty) Text('Predicción: $_prediction'),
          ],
        ),
      ),
    );
  }

  // Método para realizar la predicción
  void _predict() async {
    if (_points.isEmpty) return;

    // Convertir el dibujo a una imagen de 64x64
    img.Image image = img.Image(64, 64); // Crear una imagen en blanco de 64x64
    for (var point in _points) {
      if (point != null) {
        image.setPixel(
            (point.dx ~/ 4), (point.dy ~/ 4), img.getColor(255, 255, 255)); // Escalar las coordenadas
      }
    }

    // Convertir la imagen a una matriz de píxeles con valores normalizados entre 0 y 1
    Float32List input = _processImage(image);

    // Realizar la predicción
    var output = List.filled(1, List.filled(1000, 0.0));

    _interpreter.run(input, output);

    // Obtener el resultado y asignar la predicción
    int predictedIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
    setState(() {
      _prediction = _labels[predictedIndex];
    });
  }

  // Procesar la imagen: convertirla a un formato adecuado para el modelo
  Float32List _processImage(img.Image image) {
    // Convertir la imagen a un formato adecuado para el modelo (64x64, 3 canales)
    List<List<List<double>>> pixels = List.generate(64,
            (i) => List.generate(64, (j) {
          int pixel = image.getPixel(j, i);
          // Extraer los canales R, G, B
          double r = img.getRed(pixel) / 255.0;
          double g = img.getGreen(pixel) / 255.0;
          double b = img.getBlue(pixel) / 255.0;
          return [r, g, b];
        }));

    // Convertir la lista 3D en un array 1D de tipo Float32
    Float32List flattened = Float32List(64 * 64 * 3);
    int index = 0;
    for (var row in pixels) {
      for (var pixel in row) {
        flattened[index++] = pixel[0];
        flattened[index++] = pixel[1];
        flattened[index++] = pixel[2];
      }
    }

    return flattened;
  }
}

// CustomPainter para dibujar sobre la pantalla
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (var point in points) {
      if (point != null) {
        canvas.drawCircle(point, 5.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}