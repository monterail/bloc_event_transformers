import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';

part 'skip_event.dart';
part 'skip_state.dart';

class SkipBloc extends Bloc<SkipEvent, SkipState> {
  SkipBloc(int count) : super(const SkipState()) {
    on<NewSkipEvent>(
      _handleThrottledEvent,
      transformer: skip(count),
    );
  }

  FutureOr<void> _handleThrottledEvent(
    NewSkipEvent event,
    Emitter<SkipState> emit,
  ) {
    emit(SkipState(count: event.count));
  }
}
