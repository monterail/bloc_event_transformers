part of 'skip_bloc.dart';

class SkipState extends Equatable {
  final int count;

  const SkipState({this.count = 0});

  @override
  List<Object?> get props => [count];
}
