part of '../bloc_event_transformers.dart';

/// Skips the first [count] events.
///
/// ### Example
///
///     on<ExampleEvent>(
///       _handleEvent,
///       transformer: skip(10),
///     )
EventTransformer<Event> skip<Event>(int count) =>
    (events, mapper) => events.skip(count).switchMap(mapper);
