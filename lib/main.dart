import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/club_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool chiaro = false;
  try {
    chiaro = await SettingsService.isTemaChiaro();
  } catch (e) {
    chiaro = false;
  }
  try {
    await Firebase.initializeApp();
    await ClubService.inizializzaFondatori();
  } catch (e) {
    // Cloud non raggiungibile: l'app parte comunque, riproverà dopo.
  }
  runApp(MyApp(temaChiaro: chiaro));
}

class MyApp extends StatelessWidget {
  final bool temaChiaro;

  const MyApp({super.key, required this.temaChiaro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Nuova Milano Carpfishing',
      theme: temaChiaro ? AppTheme.chiaro() : AppTheme.scuro(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
