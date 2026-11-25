// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:bloc_test/bloc_test.dart';

import 'bloc/throttle_bloc.dart';

void main() {
  const throttleWindow = Duration(milliseconds: 10);
  blocTest<ThrottleBloc, ThrottleState>(
    'Throttles events',
    build: () => ThrottleBloc(throttleWindow),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewThrottleEvent(count + 1)))
        .toList(),
    wait: throttleWindow * 2,
    expect: () => [const ThrottleState(count: 1)],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'trailing: true sends last event to handler',
    build: () => ThrottleBloc(throttleWindow, trailing: true, leading: false),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewThrottleEvent(count + 1)))
        .toList(),
    wait: throttleWindow * 2,
    expect: () => [const ThrottleState(count: 100)],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'trailing: true, leading: true sends first and last event to handler',
    build: () => ThrottleBloc(throttleWindow, trailing: true, leading: true),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewThrottleEvent(count + 1)))
        .toList(),
    wait: throttleWindow * 2,
    expect: () => [
      const ThrottleState(count: 1),
      const ThrottleState(count: 100),
    ],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'Throttles events in two windows',
    build: () => ThrottleBloc(throttleWindow),
    act: (bloc) async {
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewThrottleEvent(count + 1)));
      await Future.delayed(throttleWindow * 1.5);
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewThrottleEvent(count + 101)));
    },
    wait: throttleWindow * 2,
    expect: () => [
      const ThrottleState(count: 1),
      const ThrottleState(count: 101),
    ],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'Handles a single event',
    build: () => ThrottleBloc(throttleWindow),
    act: (bloc) => bloc.add(NewThrottleEvent(1)),
    wait: throttleWindow * 2,
    expect: () => [const ThrottleState(count: 1)],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'trailing: true, leading: true handles a single event once',
    build: () => ThrottleBloc(throttleWindow, trailing: true, leading: true),
    act: (bloc) => bloc.add(NewThrottleEvent(1)),
    wait: throttleWindow * 2,
    expect: () => [const ThrottleState(count: 1)],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'trailing: true, leading: false handles a single event',
    build: () => ThrottleBloc(throttleWindow, trailing: true, leading: false),
    act: (bloc) => bloc.add(NewThrottleEvent(1)),
    wait: throttleWindow * 2,
    expect: () => [const ThrottleState(count: 1)],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'trailing: false, leading: false does not handle any events',
    build: () => ThrottleBloc(throttleWindow, trailing: false, leading: false),
    act: (bloc) => List.generate(10, (index) => index)
        .map((count) => bloc.add(NewThrottleEvent(count + 1)))
        .toList(),
    wait: throttleWindow * 2,
    expect: () => [],
  );

  blocTest<ThrottleBloc, ThrottleState>(
    'Does not trigger if no events are added',
    build: () => ThrottleBloc(throttleWindow),
    wait: throttleWindow * 2,
    expect: () => [],
  );
}
