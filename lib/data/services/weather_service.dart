import 'dart:convert';
import 'package:http/http.dart' as http; // Harus pakai package:http/http.dart
import '../models/weather_model.dart';

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey = "7456bf7199b889489fb4d22df0189e25";

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse("$BASE_URL?q=$cityName&appid=$apiKey&units=metric"),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal mengambil data cuaca");
    }
  }
}
