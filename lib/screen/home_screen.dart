import 'dart:ui'; // Wajib untuk Glassmorphism (BackdropFilter)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:provider/provider.dart';
// import 'package:weather_icons/weather_icons.dart'; // Package ikon keren
import '../providers/weather_providers.dart';
import '../data/models/weather_model.dart';
import '../screen//favorit_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Panggil Medan secara otomatis saat aplikasi dibuka
    Future.microtask(
      () => Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeather("Medan"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProv = Provider.of<WeatherProvider>(context);
    final theme = Theme.of(context);

    // Dapatkan data cuaca utama atau gunakan dummy jika loading/error
    final mainWeather = weatherProv.weather;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true, // Appbar jadi transparan di atas background
      appBar: AppBar(
        title: Text(
          "Cuaca Kita",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (weatherProv.weather !=
              null) // Tombol hanya muncul jika data cuaca sukses dimuat
            IconButton(
              icon: Icon(
                weatherProv.isCurrentCityFavorite
                    ? Icons
                          .bookmark // Ikon berubah jadi bookmark kalau sudah tersimpan di SQLite
                    : Icons.add_circle_outline, // Ikon + kalau belum tersimpan
                color: Colors.white,
                size: 26,
              ),
              onPressed: () async {
                // Panggil fungsi toggle yang baru kita buat di provider
                await weatherProv.toggleFavorite();

                // Tampilkan notifikasi kecil (Snackbar) biar makin interaktif
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      weatherProv.isCurrentCityFavorite
                          ? "${weatherProv.weather!.cityName} berhasil disimpan ke favorit!"
                          : "${weatherProv.weather!.cityName} dihapus dari favorit.",
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

          IconButton(
            icon: Icon(
              weatherProv.isCelsius
                  ? Icons.thermostat_rounded
                  : Icons.device_thermostat_rounded,
              color: weatherProv.isCelsius
                  ? Colors.blueAccent
                  : Colors.orangeAccent,
            ),
            tooltip: weatherProv.isCelsius
                ? "Ubah ke Fahrenheit"
                : "Ubah ke Celsius",
            onPressed: () {
              weatherProv.toggleTemperatureUnit();
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.list_alt_rounded,
              color: Colors.white,
              size: 26,
            ),
            tooltip: "Daftar Favorit",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),

          // Ganti tombol search di AppBar biar rapi
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Tampilkan search modal atau pindah screen
              _showSearchDialog(context, weatherProv);
            },
          ),
        ],
      ),
      body: weatherProv.isLoading
          ? Center(child: CircularProgressIndicator())
          : mainWeather == null
          ? Center(child: Text("Cari kota atau pastikan internet aktif."))
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: mainWeather.getBackgroundGradient(),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Nama Kota & Tanggal)
                      Text(
                        mainWeather.cityName,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 40),

                      // 2. Main Card (Glassmorphism)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10.0,
                            sigmaY: 10.0,
                          ), // Efek Kaca
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Suhu Besar
                                    Text(
                                      _formatTemperature(
                                        mainWeather.temperature,
                                        weatherProv.isCelsius,
                                      ),
                                      style: theme.textTheme.displayMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 8),
                                    // Kondisi
                                    Text(
                                      mainWeather.condition.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                // Ikon Cuaca Besar (Pakai weather_icons)
                                Icon(
                                  _getWeatherIcon(mainWeather.condition),
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // 3. Ramalan 4 Hari Kedepan (UI Modern)
                      Row(
                        children: [
                          Text(
                            "Perkiraan 4 Hari Ke depan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 140,
                        // ListView.horizontal untuk scroll samping
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4, // Ambil 4 hari
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            // Kita belum implementasi service Forecast,
                            // Jadi kita pakai dummy data dulu untuk hari ke 2-4
                            final forecastDate = DateTime.now().add(
                              Duration(days: index + 1),
                            );
                            final dummyTemp =
                                (mainWeather.temperature + (index - 1) * 0.5);

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 100,
                                padding: EdgeInsets.all(12),
                                color: Colors.white.withOpacity(0.1),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Nama Hari Singkat
                                    Text(
                                      DateFormat('EEE').format(forecastDate),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Ikon
                                    Icon(
                                      _getWeatherIcon(mainWeather.condition),
                                      size: 36,
                                      color: Colors.white70,
                                    ),
                                    // Suhu dummy
                                    Text(
                                      _formatTemperature(
                                        dummyTemp,
                                        weatherProv.isCelsius,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Fungsi pembantu untuk memetakan nama kondisi API ke Ikon WeatherIcons
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'clear':
        return Icons.sunny;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _formatTemperature(double? tempCelsius, bool isCelsius) {
    if (tempCelsius == null) return "--";

    if (isCelsius) {
      // Jika Celsius, bulatkan dan tambah simbol °C
      return "${tempCelsius.toStringAsFixed(0)}°C";
    } else {
      // Jika Fahrenheit, hitung rumus: (C * 9/5) + 32
      double tempFahrenheit = (tempCelsius * 9 / 5) + 32;
      return "${tempFahrenheit.toStringAsFixed(0)}°F";
    }
  }

  void _showSearchDialog(BuildContext context, WeatherProvider provider) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Search",
      pageBuilder: (context, anim1, anim2) => Container(), // Tidak dipakai
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.1), // Transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Efek Kaca
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Cari Kota",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          style: TextStyle(color: Colors.white),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Contoh: Tokyo, New York...",
                            hintStyle: TextStyle(color: Colors.white54),
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Batal",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  if (_controller.text.isNotEmpty) {
                                    provider.fetchWeather(_controller.text);
                                    _controller.clear();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  "Cari Sekarang",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
