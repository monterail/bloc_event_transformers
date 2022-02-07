import 'package:bloc_test/bloc_test.dart';

import 'bloc/delay_bloc.dart';

void main() {
  const delayWindow = Duration(milliseconds: 100);
  blocTest<DelayBloc, DelayState>(
    'Delays events',
    build: () => DelayBloc(delayWindow),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewDelayEvent(count + 1)))
        .toList(),
    wait: delayWindow,
    expect: () => List<DelayState>.generate(
      100,
      (index) => DelayState(count: index + 1),
    ),
  );

  blocTest<DelayBloc, DelayState>(
    'Delayed events are not processed until time passes',
    build: () => DelayBloc(delayWindow),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewDelayEvent(count + 1)))
        .toList(),
    wait: Duration.zero,
    expect: () => [],
  );
}
