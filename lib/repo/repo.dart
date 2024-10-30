import 'dart:convert';
import 'package:earnings_tracker/Model/earning_mode.dart';
import 'package:http/http.dart' as http;

Future<List<EarningsData>> fetchEarningsData(String ticker) async {
  final url = Uri.parse('https://api-ninjas.com/api/earningscalendar');

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
