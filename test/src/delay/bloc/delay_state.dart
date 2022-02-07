part of 'delay_bloc.dart';

class DelayState extends Equatable {
  final int count;

  const DelayState({this.count = 0});

  @override
  List<Object?> get props => [count];
}
