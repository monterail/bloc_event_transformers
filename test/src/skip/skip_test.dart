import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
