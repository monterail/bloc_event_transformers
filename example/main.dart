import 'package:bloc/bloc.dart';
import 'package:bloc_event_transformers/bloc_event_transformers.dart';

abstract class SearchEvent {}

class QueryChanged extends SearchEvent {
  QueryChanged(this.query);
  final String query;
}

class SearchBloc extends Bloc<SearchEvent, String> {
  SearchBloc() : super('') {
    on<QueryChanged>(
      (event, emit) => emit(event.query),
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }
}

Future<void> main() async {
  final bloc = SearchBloc();
  bloc.stream.listen((q) => print('handled: $q'));
  for (final q in ['d', 'da', 'dar', 'dart']) {
    bloc.add(QueryChanged(q));
  }
  await Future<void>.delayed(const Duration(seconds: 1));
  await bloc.close();
}
