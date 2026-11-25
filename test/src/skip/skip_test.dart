import 'package:bloc_test/bloc_test.dart';

import 'bloc/skip_bloc.dart';

void main() {
  blocTest<SkipBloc, SkipState>(
    'Skips events',
    build: () => SkipBloc(50),
    act: (bloc) => List.generate(100, (index) => index)
        .map((count) => bloc.add(NewSkipEvent(count)))
        .toList(),
    expect: () => List<SkipState>.generate(
      50,
      (index) => SkipState(count: index + 50),
    ),
  );

  blocTest<SkipBloc, SkipState>(
    'Does not trigger if there\'re not enough events added',
    build: () => SkipBloc(50),
    act: (bloc) => List.generate(50, (index) => index)
        .map((count) => bloc.add(NewSkipEvent(count)))
        .toList(),
    expect: () => [],
  );

  blocTest<SkipBloc, SkipState>(
    'Skips nothing when count is zero',
    build: () => SkipBloc(0),
    act: (bloc) => List.generate(3, (index) => index)
        .map((count) => bloc.add(NewSkipEvent(count + 1)))
        .toList(),
    expect: () => List<SkipState>.generate(
      3,
      (index) => SkipState(count: index + 1),
    ),
  );

  blocTest<SkipBloc, SkipState>(
    'Handles only the first event after the skipped ones',
    build: () => SkipBloc(50),
    act: (bloc) => List.generate(51, (index) => index)
        .map((count) => bloc.add(NewSkipEvent(count)))
        .toList(),
    expect: () => [const SkipState(count: 50)],
  );

  blocTest<SkipBloc, SkipState>(
    'Does not trigger if no events are added',
    build: () => SkipBloc(1),
    expect: () => [],
  );
}
