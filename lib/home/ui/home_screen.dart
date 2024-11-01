import 'package:earnings_tracker/home/bloc/home_bloc.dart';
import 'package:earnings_tracker/home/bloc/home_event.dart';
import 'package:earnings_tracker/home/bloc/home_state.dart';
import 'package:earnings_tracker/repo/repo.dart';
import 'package:earnings_tracker/transcript/ui/transcript_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController tickerController = TextEditingController();
  bool isTranscriptOpen = false; // Flag to check if transcript is open
  Timer? longPressTimer; // Timer to manage long press detection

  @override
  void initState() {
    super.initState();
    tickerController.text = 'AAPL'; // Default ticker symbol
  }

  void onNodeTap(BuildContext context, int index) async {
    if (isTranscriptOpen)
      return; // Prevent opening if transcript is already open
    isTranscriptOpen = true; // Set flag to true
    const year = 2024; // Placeholder; update as per your data
    final quarter = (index % 4) + 1;

    try {
      final transcript =
          await fetchTranscriptData(tickerController.text, year, quarter);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranscriptScreen(transcript: transcript),
        ),
      ).then((_) {
        // Reset flag when returning from TranscriptScreen
        isTranscriptOpen = false;
      });
    } catch (e) {
      isTranscriptOpen = false; // Reset flag on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load transcript: $e")),
      );
    }
  }

  void onNodeLongPress(BuildContext context, int index) {
    // Cancel any existing timer
    longPressTimer?.cancel();
    final actualRevenue =
        context.read<HomeBloc>().state.actualRevenueData[index];
    final estimatedRevenue =
        context.read<HomeBloc>().state.estimatedRevenueData[index];

    // Displaying the actual and estimated revenue using a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Actual: \$${actualRevenue}B, Estimated: \$${estimatedRevenue}B',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    tickerController.dispose();
    longPressTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Earnings Tracker'),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.grey,
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.homeStatus == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.homeStatus == HomeStatus.error) {
              return const Center(
                child: Text("Error fetching data"),
              );
            }

            double maxActual = state.actualRevenueData.isNotEmpty
                ? state.actualRevenueData.reduce((a, b) => a > b ? a : b)
                : 0;
            double maxEstimated = state.estimatedRevenueData.isNotEmpty
                ? state.estimatedRevenueData.reduce((a, b) => a > b ? a : b)
                : 0;
            double maxY =
                (maxActual > maxEstimated ? maxActual : maxEstimated) + 10;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter Ticker Symbol:',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    cursorWidth: 5,
                    cursorColor: Colors.black.withOpacity(0.5),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: tickerController,
                    decoration: InputDecoration(
                      labelText: 'Ticker Symbol',
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 3)),
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      String ticker = tickerController.text.trim();
                      if (ticker.isNotEmpty) {
                        context.read<HomeBloc>().add(FetchDataEvent(ticker));
                      }
                    },
                    child: const Text('Fetch Earnings Data'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Actual vs Estimated Revenue (in Billions)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(LineChartData(
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            state.actualRevenueData.length,
                            (index) => FlSpot(index.toDouble(),
                                state.actualRevenueData[index]),
                          ),
                          isCurved: true,
                          color: Colors.grey[800]!,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.grey[800]!.withOpacity(0.2),
                          ),
                          barWidth: 4,
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            state.estimatedRevenueData.length,
                            (index) => FlSpot(index.toDouble(),
                                state.estimatedRevenueData[index]),
                          ),
                          isCurved: true,
                          color: Colors.red[800]!,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red[800]!.withOpacity(0.2),
                          ),
                          barWidth: 4,
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) {
                              return Text(
                                '${value.toStringAsFixed(0)} B',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              if (index >= 0 && index < state.quarters.length) {
                                return Text(
                                  state.quarters[index],
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchCallback: (event, response) {
                          if (response != null &&
                              response.lineBarSpots != null) {
                            if (event is FlTapDownEvent) {
                              // Cancel the long press timer if tap detected
                              longPressTimer?.cancel();
                              // Handle tap event
                              onNodeTap(
                                  context, response.lineBarSpots![0].spotIndex);
                            } else if (event is FlLongPressStart) {
                              // Start long press timer to delay the tap action
                              longPressTimer
                                  ?.cancel(); // Cancel any existing timer
                              longPressTimer =
                                  Timer(const Duration(milliseconds: 300), () {
                                final index =
                                    response.lineBarSpots![0].spotIndex;
                                onNodeLongPress(context, index);
                              });
                            }
                          }
                        },
                      ),
                    )),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
