import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final List<double> actualRevenueData;
  final List<double> estimatedRevenueData;
  final List<String> quarters;
  final HomeStatus homeStatus;
  final String message;

  const HomeState({
    this.message = '',
    this.homeStatus = HomeStatus.initial,
    this.actualRevenueData = const [],
    this.estimatedRevenueData = const [],
    this.quarters = const [],
  });

  HomeState copyWith({
    List<double>? actualRevenueData,
    List<double>? estimatedRevenueData,
    List<String>? quarters,
    HomeStatus? homestatus,
    String? message,
  }) {
    return HomeState(
      actualRevenueData: actualRevenueData ?? this.actualRevenueData,
      estimatedRevenueData: estimatedRevenueData ?? this.estimatedRevenueData,
      quarters: quarters ?? this.quarters,
      homeStatus: homestatus ?? homeStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        actualRevenueData,
        estimatedRevenueData,
        quarters,
        homeStatus,
        message,
      ];
}
