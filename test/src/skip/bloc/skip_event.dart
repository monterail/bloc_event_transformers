part of 'skip_bloc.dart';

abstract class SkipEvent extends Equatable {}

class NewSkipEvent extends SkipEvent {
  final int count;

  NewSkipEvent(this.count);

  @override
  List<Object?> get props => [count];
}
