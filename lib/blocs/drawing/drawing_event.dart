part of 'drawing_bloc.dart';

abstract class DrawingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClearCanvas extends DrawingEvent {}

class PredictLetter extends DrawingEvent {
  final List<List<int>> imageData;

  PredictLetter(this.imageData);

  @override
  List<Object?> get props => [imageData];
}