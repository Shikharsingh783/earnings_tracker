import 'dart:convert';
import 'package:earnings_tracker/Model/earning_mode.dart';
import 'package:http/http.dart' as http;

Future<List<EarningsData>> fetchEarningsData(String ticker) async {
  final url = Uri.parse(
      'https://api.api-ninjas.com/v1/earningscalendar?ticker=$ticker');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => EarningsData.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load earnings data");
    }
  } catch (e) {
    print(e);
    throw Exception("Error fetching data: $e");
  }
}

Future<String> fetchTranscriptData(String ticker, int year, int quarter) async {
  final url = Uri.parse(
      'https://api.api-ninjas.com/v1/earningstranscript?ticker=$ticker&year=$year&quarter=$quarter');

  try {
    final response = await http.get(
      url,
      headers: {
        'X-Api-Key': 'OjDPTjE8tEisUA/LOPRj+A==fOekwR6wssGOxmbG',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['transcript'] ?? "Transcript not available.";
    } else {
      throw Exception("Failed to load transcript data");
    }
  } catch (e) {
    print(e);
    throw Exception("Error fetching transcript data: $e");
  }
}
