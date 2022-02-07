import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';

part 'delay_event.dart';
part 'delay_state.dart';

class DelayBloc extends Bloc<DelayEvent, DelayState> {
  DelayBloc(Duration duration) : super(const DelayState()) {
    on<NewDelayEvent>(
      _handleThrottledEvent,
      transformer: delay(duration),
    );
  }

  FutureOr<void> _handleThrottledEvent(
    NewDelayEvent event,
    Emitter<DelayState> emit,
  ) {
    emit(DelayState(count: event.count));
  }
}
