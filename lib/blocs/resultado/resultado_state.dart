part of 'resultado_bloc.dart';

class ResultadoState extends Equatable {
  String ResultadoObject;
  Double probabilidad;


  ResultadoState(this.ResultadoObject, this.probabilidad);

  @override
  // TODO: implement props
  List<Object?> get props =>[ResultadoObject,probabilidad] ;

}

