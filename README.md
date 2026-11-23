# BLoC event transformers

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.)
<img src="https://raw.githubusercontent.com/monterail/bloc_event_transformers/development/doc/assets/monterail_logo.svg" alt="Monterail's logo" width="25%" height="100" align="right"/>

Skip implementing transformers on your own and
configure timings in which events in your BLoC's are processed.

Available transformers:

- [throttle](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/throttle.html) (see [visualization](https://rxmarbles.com/#throttleTime))
- [debounce](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/debounce.html) (see [visualization](https://rxmarbles.com/#debounceTime))
- [skip](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/skip.html) (see [visualization](https://rxmarbles.com/#skip))
- [delay](https://pub.dev/documentation/bloc_event_transformers/latest/bloc_event_transformers/delay.html) (see [visualization](https://rxmarbles.com/#delay))

## Installation

```yaml
dependencies:
  bloc_event_transformers: ^2.0.0
```

## Usage

Pass a transformer to `on<Event>()`. A complete runnable example lives in [example/main.dart](example/main.dart).

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<QueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }
}
```

Common recipes:

| Goal | Transformer |
| --- | --- |
| Search-as-you-type | `debounce(const Duration(milliseconds: 300))` |
| Prevent double-tap / button spam | `throttle(const Duration(seconds: 1))` |
| Act on the last event of a burst | `throttle(duration, leading: false, trailing: true)` |
| Ignore initial events (e.g. a replayed value) | `skip(1)` |
| Defer handling by a fixed time | `delay(const Duration(seconds: 1))` |

## Good to know

- Every transformer here maps events with `switchMap`, so when a new event
  reaches the handler, the handler for the previous event is cancelled
  (its emits are dropped). This matches `restartable()` from `bloc_concurrency`.
- `throttle` emits the leading event by default (`leading: true`, `trailing: false`).
- Transformers are set per `on<Event>()` registration, so different events can use different timings.

## Related packages

- [bloc_concurrency](https://pub.dev/packages/bloc_concurrency): `concurrent`, `sequential`, `droppable`, `restartable`. Controls how handlers overlap rather than when events are emitted.
- [rxdart](https://pub.dev/packages/rxdart) (used here) and [stream_transform](https://pub.dev/packages/stream_transform): general stream operators these transformers are built on or comparable to.

## Development

Tool versions (Dart) are managed with [mise](https://mise.jdx.dev). With mise installed:

```sh
mise install   # installs the Dart version pinned in mise.toml
mise run get   # dart pub get
mise run test  # dart test
```
