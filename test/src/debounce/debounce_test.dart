// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:bloc_test/bloc_test.dart';

import 'bloc/debounce_bloc.dart';

void main() {
  const debounceWindow = Duration(milliseconds: 10);
  blocTest<DebounceBloc, DebounceState>(
    'Debounces events',
    build: () => DebounceBloc(debounceWindow),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewDebounceEvent(count + 1)))
        .toList(),
    wait: debounceWindow * 2,
    expect: () => [const DebounceState(count: 100)],
  );

  blocTest<DebounceBloc, DebounceState>(
    'Debounces events in two windows',
    build: () => DebounceBloc(debounceWindow),
    act: (bloc) async {
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewDebounceEvent(count + 1)));
      await Future.delayed(debounceWindow * 3);
      List.generate(100, (index) => index)
          .forEach((count) => bloc.add(NewDebounceEvent(count + 101)));
    },
    wait: debounceWindow * 10,
    expect: () => [
      const DebounceState(count: 100),
      const DebounceState(count: 200),
    ],
  );
}
