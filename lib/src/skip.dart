part of bloc_event_transformers;

/// Skips the first [count] events.
EventTransformer<Event> skip<Event>(int count) =>
    (events, mapper) => events.skip(count).switchMap(mapper);
