import 'package:flutter/material.dart';

class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final DateTime date; // Tambahkan untuk tanggal

  Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.date, // Ganti ini
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Parsing tanggal dari format API (dt)
    var dateFromApi = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);

    return Weather(
      cityName:
          json['name'] ?? "Unknown", // Handle null city name (for forecast)
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      date: dateFromApi, // Gunakan parse date
    );
  }

  // Method pembantu untuk get Warna Background berdasarkan kondisi
  Gradient getBackgroundGradient() {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return LinearGradient(
          colors: [Colors.grey[700]!, Colors.grey[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'rain':
        return LinearGradient(
          colors: [Color(0xff4a5a70), Color(0xff2a3440)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'clear':
        return LinearGradient(
          colors: [Color(0xff57a2f5), Color(0xffa1c4fd)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return LinearGradient(
          colors: [Color(0xff2d6cb5), Color(0xff74b8fc)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}
