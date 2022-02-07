import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

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
      await Future.delayed(throttleWindow);
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewThrottleEvent(count + 101)));
    },
    wait: throttleWindow * 2,
    expect: () => [
      const ThrottleState(count: 1),
      const ThrottleState(count: 101),
    ],
  );
}
