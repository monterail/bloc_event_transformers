part of 'throttle_bloc.dart';

class ThrottleState extends Equatable {
  final int count;

  const ThrottleState({this.count = 0});

  @override
  List<Object?> get props => [count];
}
