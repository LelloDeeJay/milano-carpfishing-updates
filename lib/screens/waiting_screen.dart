import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  Future<void> _esci(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggato', false);
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nero,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: AppTheme.oro, size: 70),
              const SizedBox(height: 24),
              const Text('ISCRIZIONE RICEVUTA', style: AppTheme.titoloMedio, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('La tua richiesta è stata inviata ai soci fondatori della Sede 303 CFI.', style: AppTheme.testoBianco, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Il tuo tesserino sarà attivato dopo l\'approvazione di un socio fondatore.', style: TextStyle(color: AppTheme.grigio, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () => _esci(context),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro)),
                child: const Text('ESCI', style: TextStyle(color: AppTheme.oro)),
              ),
              const SizedBox(height: 20),
              const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
