part of bloc_event_transformers;

/// Event transformer that will only emit items from the source
/// sequence whenever the time span defined by [duration] passes, without the
/// source sequence emitting another item.
///
/// This time span start after the last debounced event was emitted.
///
/// debounce filters out items obtained events that are
/// rapidly followed by another emitted event.
///
/// [Interactive marble diagram](http://rxmarbles.com/#debounceTime)
///
/// ### Example
///
///     on<ExampleEvent>(
///       _handleEvent,
///       transformer: debounce(const Duration(seconds: 1)),
///     );
EventTransformer<Event> debounce<Event>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).switchMap(mapper);
