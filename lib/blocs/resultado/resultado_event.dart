part of 'resultado_bloc.dart';

sealed class ResultadoEvent extends Equatable {
  const ResultadoEvent();
}

class mostrarResultado extends ResultadoEvent{
  String Objeto;
  Double probabilidad;

  mostrarResultado(this.Objeto, this.probabilidad);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

}
