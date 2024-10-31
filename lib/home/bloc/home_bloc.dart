import 'package:bloc/bloc.dart';
import 'package:earnings_tracker/home/bloc/home_event.dart';
import 'package:earnings_tracker/home/bloc/home_state.dart';
import 'package:earnings_tracker/repo/repo.dart';
import 'package:earnings_tracker/Model/earning_mode.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<FetchDataEvent>(fetchDataEvent);
  }

  void fetchDataEvent(FetchDataEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(homestatus: HomeStatus.loading));

    try {
      // Fetch earnings data based on the ticker symbol
      List<EarningsData> earningsDataList =
          await fetchEarningsData(event.ticker);

      // Process the data to get the needed lists for the chart
      List<double> actualRevenueData =
          earningsDataList.map((e) => (e.actualRevenue ?? 0) / 1e9).toList();
      List<double> estimatedRevenueData =
          earningsDataList.map((e) => (e.estimatedRevenue ?? 0) / 1e9).toList();
      List<String> quarters =
          earningsDataList.map((e) => e.pricedate.substring(0, 7)).toList();

      // Emit the loaded state with the processed data
      emit(state.copyWith(
        actualRevenueData: actualRevenueData,
        estimatedRevenueData: estimatedRevenueData,
        quarters: quarters,
        homestatus: HomeStatus.loaded,
      ));
    } catch (e) {
      // Emit error state if fetching fails
      emit(state.copyWith(
        homestatus: HomeStatus.error,
        message: e.toString(),
      ));
    }
  }
}
