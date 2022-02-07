part of 'debounce_bloc.dart';

abstract class DebounceEvent extends Equatable {}

class NewDebounceEvent extends DebounceEvent {
  final int count;

  NewDebounceEvent(this.count);

  @override
  List<Object?> get props => [count];
}
