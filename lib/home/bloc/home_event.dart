import 'package:equatable/equatable.dart';

class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDataEvent extends HomeEvent {
  final String ticker;

  FetchDataEvent(this.ticker);

  @override
  List<Object?> get props => [ticker];
}
