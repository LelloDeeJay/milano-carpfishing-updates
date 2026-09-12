import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/club_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Prova a inizializzare Firebase, ma non bloccare l'app se fallisce
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase non inizializzato: $e');
  }
  
  bool chiaro = false;
  try {
    chiaro = await SettingsService.isTemaChiaro();
  } catch (e) {
    chiaro = false;
  }
  
  try {
    await ClubService.inizializzaFondatori();
  } catch (e) {
    debugPrint('Errore inizializzazione cloud: $e');
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
