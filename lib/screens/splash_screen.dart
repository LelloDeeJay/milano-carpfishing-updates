import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'waiting_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Uint8List? _logoCloud;

  @override
  void initState() {
    super.initState();
    _caricaLogo();
    _vai();
  }

  Future<void> _caricaLogo() async {
    try {
      final b64 = await SettingsService.getLogoBase64();
      if (b64 != null && mounted) {
        setState(() => _logoCloud = base64Decode(b64));
      }
    } catch (e) {
      // Cloud non raggiungibile: resto sul logo locale.
    }
  }

  Future<void> _vai() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final loggato = prefs.getBool('loggato') ?? false;
    final attivo = prefs.getBool('attivo') ?? false;
    if (!mounted) return;
    if (loggato && attivo) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (loggato) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WaitingScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nero,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LA NUOVA MILANO', style: AppTheme.titoloGrande, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('CARPFISHING A.S.D.', style: AppTheme.titoloGrande, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.oro, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: _logoCloud != null
                    ? Image.memory(_logoCloud!, fit: BoxFit.cover)
                    : Image.asset('assets/logo_cfi.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sede 303 CFI', style: AppTheme.sottotitolo),
            const SizedBox(height: 30),
            Container(
              color: AppTheme.verde,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: const Text('PASSIONE • RISPETTO • AMICIZIA • NATURA', style: AppTheme.valori),
            ),
            const SizedBox(height: 20),
            const Text(
              'Questa App è stata creata e realizzata da C.R.Software Milano\ninfo cierre.software@gmail.com',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grigio, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
