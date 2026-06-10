import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_providers.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Pastikan list favorit selalu paling update saat halaman ini dibuka
    Future.microtask(
      () =>
          Provider.of<WeatherProvider>(context, listen: false).loadFavorites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProv = Provider.of<WeatherProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Desain background gradasi gelap agar serasi dengan HomeScreen kamu
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3440), Color(0xFF1A1C23)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header / App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Kota Favorit Saya",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Kondisi jika data favorit kosong
              Expanded(
                child: weatherProv.favoriteCities.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada kota yang disimpan.",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: weatherProv.favoriteCities.length,
                        itemBuilder: (context, index) {
                          final cityName = weatherProv.favoriteCities[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: Colors.blueAccent,
                                      size: 28,
                                    ),
                                    title: Text(
                                      cityName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight(540),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        // Pura-puranya kita set cuaca ke kota itu sebentar lalu hapus
                                        // Atau bisa langsung bikin method khusus hapus di provider nanti.
                                        // Tapi trik gampangnya, kita panggil fetch lalu toggle.
                                        await weatherProv.fetchWeather(
                                          cityName,
                                        );
                                        await weatherProv.toggleFavorite();

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "$cityName dihapus dari favorit.",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      // Jika kota diklik, langsung fetch cuacanya dan balik ke halaman utama
                                      weatherProv.fetchWeather(cityName);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
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
    );
  }
}
