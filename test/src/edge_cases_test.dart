import 'dart:async';

import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:test/test.dart';

import 'debounce/bloc/debounce_bloc.dart';
import 'delay/bloc/delay_bloc.dart';
import 'skip/bloc/skip_bloc.dart';
import 'throttle/bloc/throttle_bloc.dart';

Stream<int> _identity(int e) => Stream.value(e);

Future<List<int>> _run(
  Stream<int> Function(Stream<int>, Stream<int> Function(int)) transformer,
  Stream<int> source,
) =>
    transformer(source, _identity).toList();

void main() {
  group('skip', () {
    test('skip(0) passes every event through', () async {
      final bloc = SkipBloc(0);
      final states = <SkipState>[];
      final sub = bloc.stream.listen(states.add);
      for (var i = 1; i <= 3; i++) {
        bloc.add(NewSkipEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(states.map((s) => s.count), [1, 2, 3]);
      await sub.cancel();
      await bloc.close();
    });

    test('skip(n) with n greater than event count emits nothing', () async {
      expect(
          await _run(skip<int>(10), Stream.fromIterable([1, 2, 3])), isEmpty);
    });

    test('skip on an empty stream emits nothing', () async {
      expect(await _run(skip<int>(2), const Stream<int>.empty()), isEmpty);
    });

    test('negative count is rejected', () {
      expect(
        () => skip<int>(-1)(Stream.fromIterable([1]), _identity),
        throwsArgumentError,
      );
    });

    test('state is not changed when exactly count events are added', () async {
      final bloc = SkipBloc(3);
      final states = <SkipState>[];
      final sub = bloc.stream.listen(states.add);
      for (var i = 1; i <= 3; i++) {
        bloc.add(NewSkipEvent(i));
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states, isEmpty);
      await sub.cancel();
      await bloc.close();
    });

    test('first event after count is emitted', () async {
      final bloc = SkipBloc(3);
      final future = bloc.stream.first;
      for (var i = 1; i <= 4; i++) {
        bloc.add(NewSkipEvent(i));
      }
      expect((await future).count, 4);
      await bloc.close();
    });
  });

  group('debounce', () {
    test('single event is emitted after the window', () async {
      expect(
          await _run(
              debounce<int>(const Duration(milliseconds: 10)), Stream.value(7)),
          [7]);
    });

    test('empty stream emits nothing', () async {
      expect(
        await _run(debounce<int>(const Duration(milliseconds: 10)),
            const Stream<int>.empty()),
        isEmpty,
      );
    });

    test('pending event is flushed when the source closes', () async {
      final controller = StreamController<int>();
      final result =
          _run(debounce<int>(const Duration(seconds: 10)), controller.stream);
      controller
        ..add(1)
        ..add(2);
      await controller.close();
      expect(await result, [2]);
    });

    test('bloc emits nothing before the window elapses', () async {
      final bloc = DebounceBloc(const Duration(milliseconds: 200));
      final states = <DebounceState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(NewDebounceEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(states, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(states.map((s) => s.count), [1]);
      await sub.cancel();
      await bloc.close();
    });

    test('events spaced within the window keep resetting the timer', () async {
      final bloc = DebounceBloc(const Duration(milliseconds: 150));
      final states = <DebounceState>[];
      final sub = bloc.stream.listen(states.add);
      for (var i = 1; i <= 4; i++) {
        bloc.add(NewDebounceEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(states, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(states.map((s) => s.count), [4]);
      await sub.cancel();
      await bloc.close();
    });
  });

  group('throttle', () {
    test('leading: false and trailing: false emits nothing', () async {
      expect(
        await _run(
          throttle<int>(const Duration(milliseconds: 10),
              leading: false, trailing: false),
          Stream.fromIterable([1, 2, 3]),
        ),
        isEmpty,
      );
    });

    test('single event is emitted by default', () async {
      expect(
          await _run(
              throttle<int>(const Duration(milliseconds: 10)), Stream.value(1)),
          [1]);
    });

    test('trailing with a single event does not duplicate it', () async {
      expect(
        await _run(
          throttle<int>(const Duration(milliseconds: 10), trailing: true),
          Stream.value(1),
        ),
        [1],
      );
    });

    test('trailing-only emits the last event once the window ends', () async {
      final bloc = ThrottleBloc(const Duration(milliseconds: 50),
          leading: false, trailing: true);
      final states = <ThrottleState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(NewThrottleEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(states.map((s) => s.count), [1]);
      await sub.cancel();
      await bloc.close();
    });

    test('events inside the window are dropped, later ones pass', () async {
      final bloc = ThrottleBloc(const Duration(milliseconds: 100));
      final states = <ThrottleState>[];
      final sub = bloc.stream.listen(states.add);
      bloc
        ..add(NewThrottleEvent(1))
        ..add(NewThrottleEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      bloc.add(NewThrottleEvent(3));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states.map((s) => s.count), [1, 3]);
      await sub.cancel();
      await bloc.close();
    });
  });

  group('delay', () {
    test('empty stream emits nothing', () async {
      expect(
        await _run(delay<int>(const Duration(milliseconds: 10)),
            const Stream<int>.empty()),
        isEmpty,
      );
    });

    test('Duration.zero preserves all events in order', () async {
      expect(
          await _run(delay<int>(Duration.zero), Stream.fromIterable([1, 2, 3])),
          [1, 2, 3]);
    });

    test('events are preserved in order after the delay', () async {
      expect(
        await _run(delay<int>(const Duration(milliseconds: 20)),
            Stream.fromIterable([3, 1, 2])),
        [3, 1, 2],
      );
    });

    test('bloc emits nothing before the delay and everything after', () async {
      final bloc = DelayBloc(const Duration(milliseconds: 200));
      final states = <DelayState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(NewDelayEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(states.map((s) => s.count), [1]);
      await sub.cancel();
      await bloc.close();
    });
  });
}
