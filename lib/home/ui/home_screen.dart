import 'package:earnings_tracker/Model/earning_mode.dart';
import 'package:earnings_tracker/repo/repo.dart';
import 'package:earnings_tracker/transcript/ui/transcript_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController tickerController = TextEditingController();
  List<double> actualRevenueData = [];
  List<double> estimatedRevenueData = [];
  List<String> quarters = [];
  bool isLoading = true;
  bool isTranscriptOpen = false; // Flag to check if transcript is open

  @override
  void initState() {
    super.initState();
    fetchData("AAPL");
    tickerController.text = 'AAPL';
  }

  Future<void> fetchData(String ticker) async {
    try {
      setState(() {
        isLoading = true;
      });

      List<EarningsData> earningsDataList = await fetchEarningsData(ticker);

      setState(() {
        actualRevenueData = earningsDataList
            .map((e) => (e.actualRevenue ?? 0) / 1e9)
            .toList()
            .cast<double>();
        estimatedRevenueData = earningsDataList
            .map((e) => (e.estimatedRevenue ?? 0) / 1e9)
            .toList()
            .cast<double>();
        quarters = earningsDataList
            .map((e) => e.pricedate.substring(0, 7))
            .toList()
            .cast<String>();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching earnings data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void onNodeTap(BuildContext context, int index) async {
    if (isTranscriptOpen) return; // Prevent multiple openings
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

  @override
  void dispose() {
    tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Tracker'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.grey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    controller: tickerController,
                    decoration: InputDecoration(
                      labelText: 'Ticker Symbol',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      String ticker = tickerController.text.trim();
                      if (ticker.isNotEmpty) {
                        fetchData(ticker);
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
                      maxY: (actualRevenueData + estimatedRevenueData)
                              .reduce((a, b) => a > b ? a : b) +
                          10,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            actualRevenueData.length,
                            (index) => FlSpot(
                                index.toDouble(), actualRevenueData[index]),
                          ),
                          isCurved: true,
                          color: Colors.grey[800]!,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.grey[800]!.withOpacity(0.2),
                          ),
                          barWidth: 4,
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            estimatedRevenueData.length,
                            (index) => FlSpot(
                                index.toDouble(), estimatedRevenueData[index]),
                          ),
                          isCurved: true,
                          color: Colors.red[800]!,
                          dotData: FlDotData(show: true),
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
                              if (index >= 0 && index < quarters.length) {
                                return Text(
                                  quarters[index],
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
                            onNodeTap(
                                context, response.lineBarSpots![0].spotIndex);
                          }
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
