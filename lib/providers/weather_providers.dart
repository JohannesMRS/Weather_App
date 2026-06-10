import 'package:flutter/material.dart';
import '../data/models/weather_model.dart';
import '../data/services/weather_service.dart';
import '../data/services/database_helper.dart'; // Tetap diimport untuk SQLite

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;

  // Tambahan baru untuk menampung list kota favorit dari DB
  List<String> _favoriteCities = [];
  bool _isCelsius = true; // Default awal adalah Celsius

  bool get isCelsius => _isCelsius;

  // Fungsi untuk mengganti satuan suhu (Toggle)
  void toggleTemperatureUnit() {
    _isCelsius = !_isCelsius;
    notifyListeners(); // Memberitahu UI untuk update angka suhu
  }

  final WeatherService _service = WeatherService();

  // Tambahan baru untuk memanggil Helper SQLite
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;

  // Getter untuk mengambil data list favorit dari luar class
  List<String> get favoriteCities => _favoriteCities;

  // Getter baru: Memeriksa apakah kota yang sedang tampil sudah masuk favorit atau belum
  bool get isCurrentCityFavorite {
    if (_weather == null) return false;
    return _favoriteCities.any(
      (city) => city.toLowerCase() == _weather!.cityName.toLowerCase(),
    );
  }

  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weather = await _service.getWeather(cityName);

      // Tambahan baru: Setiap sukses cari kota, langsung sinkronkan status favoritnya
      await loadFavorites();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi baru: Mengambil seluruh daftar kota dari database lokal SQLite
  Future<void> loadFavorites() async {
    final savedCities = await _dbHelper.getCities();
    _favoriteCities = savedCities.map((e) => e['name'] as String).toList();
    notifyListeners();
  }

  // Fungsi baru: Aksi ketika tombol + diklik (Tambah jika belum ada, Hapus jika sudah ada)
  Future<void> toggleFavorite() async {
    if (_weather == null) return;

    final currentCity = _weather!.cityName;

    if (isCurrentCityFavorite) {
      // Jika kota sudah ada di database, hapus dari favorit
      await _dbHelper.deleteCity(currentCity);
    } else {
      // Jika belum ada, simpan kota tersebut secara permanen ke SQLite
      await _dbHelper.insertCity(currentCity);
    }

    // Perbarui daftar lokal agar UI langsung berubah (Ikon berubah secara real-time)
    await loadFavorites();
  }
}
