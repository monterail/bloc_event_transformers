## Throttle

Emits an Event, then ignores subsequent events
for a duration, then repeats this process.

If leading is true, then the first event in each window is emitted.

If trailing is true, then the last event is emitted instead.

```dart
on<ExampleEvent>(
  _handler,
  transformer: throttle(const Duration(seconds: 5))
);
```

## Debounce

Event transformer that will only emit items from the source
sequence whenever the time span defined by [duration] passes, without the
source sequence emitting another item.

This time span start after the last debounced event was emitted.
debounce filters out items obtained events that are
rapidly followed by another emitted event.

[Interactive marble diagram](http://rxmarbles.com/#debounceTime)

```dart
on<ExampleEvent>(
  _handleEvent,
  transformer: debounce(const Duration(seconds: 1)),
);
```

## Skip

Skips the first [count] events.

```dart
on<ExampleEvent>(
  _handleEvent,
  transformer: skip(10),
);
```

## Delay

The delay() transformer is pausing adding events for a particular
increment of time (that you specify) before emitting each of the events.

This has the effect of shifting the entire sequence of
events added to the bloc forward in time by that specified increment.

[Interactive marble diagram](http://rxmarbles.com/#delay)

```dart
on<ExampleEvent>(
  _handleEvent,
  transformer: delay(const Duration(seconds: 1)),
);
```
