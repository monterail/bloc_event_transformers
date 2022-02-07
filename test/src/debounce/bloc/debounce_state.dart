part of 'debounce_bloc.dart';

class DebounceState extends Equatable {
  final int count;

  const DebounceState({this.count = 0});

  @override
  List<Object?> get props => [count];
}
