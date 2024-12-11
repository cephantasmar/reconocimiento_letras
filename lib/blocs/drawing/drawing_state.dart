part of 'drawing_bloc.dart';


abstract class DrawingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DrawingInitial extends DrawingState {}

class CanvasCleared extends DrawingState {}

class PredictionLoading extends DrawingState {}

class PredictionSuccess extends DrawingState {
  final String predictedLetter;

  PredictionSuccess(this.predictedLetter);

  @override
  List<Object?> get props => [predictedLetter];
}

class PredictionError extends DrawingState {}
