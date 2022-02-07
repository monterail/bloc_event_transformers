import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';

part 'debounce_event.dart';
part 'debounce_state.dart';

class DebounceBloc extends Bloc<DebounceEvent, DebounceState> {
  DebounceBloc(Duration duration) : super(const DebounceState()) {
    on<NewDebounceEvent>(
      _handleThrottledEvent,
      transformer: debounce(duration),
    );
  }

  FutureOr<void> _handleThrottledEvent(
    NewDebounceEvent event,
    Emitter<DebounceState> emit,
  ) {
    emit(DebounceState(count: event.count));
  }
}
