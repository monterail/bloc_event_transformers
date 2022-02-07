part of 'delay_bloc.dart';

abstract class DelayEvent extends Equatable {}

class NewDelayEvent extends DelayEvent {
  final int count;

  NewDelayEvent(this.count);

  @override
  List<Object?> get props => [count];
}
