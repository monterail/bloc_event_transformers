// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:bloc_test/bloc_test.dart';

import 'bloc/delay_bloc.dart';

void main() {
  const delayWindow = Duration(seconds: 1);
  blocTest<DelayBloc, DelayState>(
    'Delays events',
    build: () => DelayBloc(delayWindow),
    act: (bloc) {
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewDelayEvent(count + 1)));
    },
    wait: delayWindow * 2,
    expect: () => List<DelayState>.generate(
      100,
      (index) => DelayState(count: index + 1),
    ),
  );

  blocTest<DelayBloc, DelayState>(
    'Delayed events are not processed until time passes',
    build: () => DelayBloc(delayWindow),
    act: (bloc) {
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewDelayEvent(count + 1)));
    },
    wait: Duration.zero,
    expect: () => [],
  );
}
