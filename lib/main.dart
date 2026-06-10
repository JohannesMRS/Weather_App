import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_providers.dart';
import 'screen/home_screen.dart';

// 1. Tambahkan keyword 'async' di sini
void main() async {
  // 2. WAJIB tambahkan baris ini agar SQLite bisa diinisialisasi sebelum app berjalan
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
