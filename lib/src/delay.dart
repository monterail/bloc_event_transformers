part of bloc_event_transformers;

/// The delay() transformer is pausing adding events for a particular
/// increment of time (that you specify) before emitting each of the events.
/// This has the effect of shifting the entire sequence of
/// events added to the bloc forward in time by that specified increment.
///
/// [Interactive marble diagram](http://rxmarbles.com/#delay)
///
/// ### Example
///
///     on<ExampleEvent>(
///       _handleEvent,
///       transformer: delay(const Duration(seconds: 1)),
///     )
EventTransformer<Event> delay<Event>(Duration duration) =>
    (events, mapper) => events.delay(duration).switchMap(mapper);
