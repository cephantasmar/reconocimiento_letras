import 'dart:math';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image/image.dart' as img;
import 'package:object_recognition_app/labels.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

part 'drawing_event.dart';
part 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  late Interpreter interpreter;
  late List<String> labels;

  DrawingBloc() : super(DrawingInitial()) {
    // Registrar el manejador para el evento ClearCanvas
    on<ClearCanvas>((event, emit) {
      emit(CanvasCleared()); // Emitir el estado cuando se limpie la pizarra
    });

    // Registrar el manejador para el evento PredictLetter
    on<PredictLetter>((event, emit) async {
      emit(PredictionLoading()); // Emitir el estado de carga mientras se predice
      try {
        final processedInput = preprocessImage(listToImage(event.imageData) );
        print("preprocesado");
        // Realizar la predicción
        final result = await predictLetter(processedInput);

        emit(PredictionSuccess(result)); // Emitir el estado de éxito con la predicción
      } catch (e) {
        emit(PredictionError()); // Emitir el estado de error en caso de fallo
      }
    });
  }

  // Cargar el modelo y las etiquetas
  Future<void> loadModel() async {
    print("Cargando modelo...");
    interpreter = await Interpreter.fromAsset('assets/modelo2.tflite');

    print("Detalles del modelo:");
    print("Entradas: ${interpreter.getInputTensors()}");
    print("Salidas: ${interpreter.getOutputTensors()}");

    // Cargar etiquetas
    labels = label4; // `label` debe contener las etiquetas mapeadas al modelo.
  }

  // Función para realizar la predicción
  Future<String> predictLetter(Uint8List inputData) async {
    print("ejecuta prediccion");
    // Convertir la lista en un tensor de entrada con la forma correcta [1, 64, 64, 3]
    var input = inputData.buffer.asFloat32List().reshape([1, 64, 64, 3]);
    var output = List.filled(36, 0.0).reshape([1, 36]);
    print(inputData);

    // Ejecutar el modelo
    interpreter.run(input, output);
    print("se ejecuto");
    print(output);

    // Obtener el índice con mayor probabilidad
    //final index = output[0].indexOf(output[0].reduce(max));
    //print("index ${index}");

    double maxProb = -1;
    int maxIndex = -1;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        maxIndex = i;
      }
    }
    print("indice");
    print(maxIndex);
    print("Predicción: ${labels[maxIndex]}");
    return labels[maxIndex];
  }

  // Preprocesar la imagen dibujada
  Uint8List preprocessImage(img.Image image) {
    print("ejecuta preprocesado");
    // Redimensionar la imagen a 64x64
    final resizedImage = img.copyResize(image, width: 64, height: 64);

    // Convertir la imagen en una lista de flotantes normalizados
    final input = Float32List(64 * 64 * 3);
    int index = 0;

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // Extraer los canales RGB y normalizarlos a [0, 1]
        input[index++] = img.getRed(pixel) / 255.0;
        input[index++] = img.getGreen(pixel) / 255.0;
        input[index++] = img.getBlue(pixel) / 255.0;
      }
    }

    return Uint8List.view(input.buffer);
  }
  img.Image listToImage(List<List<int>> pixelData) {
    print("ejecuta list image");

    final height = pixelData.length;
    final width = pixelData[0].length;

    // Crear una imagen vacía
    final image = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final grayValue = pixelData[y][x];

        // Asegúrate de que el valor sea válido
        final clampedValue = grayValue.clamp(0, 255);

        // Establece el píxel en escala de grises
        image.setPixel(x, y, img.getColor(clampedValue, clampedValue, clampedValue));
      }
    }

    return image;
  }
}
