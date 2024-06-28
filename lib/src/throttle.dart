part of '../bloc_event_transformers.dart';

/// Emits an <Event>, then ignores subsequent events
/// for a [duration], then repeats this process.
///
/// If [leading] is true, then the first event in each window is emitted.
/// If [trailing] is true, then the last event is emitted instead.
///
/// ### Example
///
///     on<ExampleEvent>(
///       _handler,
///       transformer: throttle(const Duration(seconds: 5))
///     );
EventTransformer<Event> throttle<Event>(
  Duration duration, {
  bool trailing = false,
  bool leading = true,
}) =>
    (events, mapper) => events
        .throttleTime(
          duration,
          trailing: trailing,
          leading: leading,
        )
        .switchMap(mapper);
