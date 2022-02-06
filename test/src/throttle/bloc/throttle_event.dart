part of 'throttle_bloc.dart';

abstract class ThrottleEvent extends Equatable {}

class NewThrottleEvent extends ThrottleEvent {
  final int count;

  NewThrottleEvent(this.count);

  @override
  List<Object?> get props => [count];
}
