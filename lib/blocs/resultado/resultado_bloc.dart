import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'resultado_event.dart';
part 'resultado_state.dart';

class ResultadoBloc extends Bloc<ResultadoEvent, ResultadoState> {
  ResultadoBloc() : super(ResultadoState("", 0.0 as Double)) {
    on<ResultadoEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<mostrarResultado>((event,emit){
      String obj= event.Objeto;
      Double prob = event.probabilidad;
      emit(ResultadoState("El objeto es: ${obj} con una probabilidad: ",prob));
    });
  }
}

