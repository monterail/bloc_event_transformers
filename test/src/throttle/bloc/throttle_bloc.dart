import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';

part 'throttle_event.dart';
part 'throttle_state.dart';

class ThrottleBloc extends Bloc<ThrottleEvent, ThrottleState> {
  ThrottleBloc(
    Duration duration, {
    bool leading = true,
    bool trailing = false,
  }) : super(const ThrottleState()) {
    on<NewThrottleEvent>(
      _handleThrottledEvent,
      transformer: throttle(duration, trailing: trailing, leading: leading),
    );
  }

  FutureOr<void> _handleThrottledEvent(
    NewThrottleEvent event,
    Emitter<ThrottleState> emit,
  ) {
    emit(ThrottleState(count: event.count));
  }
}
