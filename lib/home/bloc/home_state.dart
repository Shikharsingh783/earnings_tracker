import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final List<double> actualRevenueData;
  final List<double> estimatedRevenueData;
  final List<String> quarters;

  HomeState({
    this.actualRevenueData = const [],
    this.estimatedRevenueData = const [],
    this.quarters = const [],
  });

  HomeState copyWith({
    List<double>? actualRevenueData,
    List<double>? estimatedRevenueData,
    List<String>? quarters,
  }) {
    return HomeState(
      actualRevenueData: actualRevenueData ?? this.actualRevenueData,
      estimatedRevenueData: estimatedRevenueData ?? this.estimatedRevenueData,
      quarters: quarters ?? this.quarters,
    );
  }

  @override
  List<Object?> get props => [
        actualRevenueData,
        estimatedRevenueData,
        quarters,
      ];
}
