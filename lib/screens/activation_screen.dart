import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _codice = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _conferma = TextEditingController();
  bool _loading = false;
  String _errore = '';

  @override
  void dispose() {
    _codice.dispose();
    _password.dispose();
    _conferma.dispose();
    super.dispose();
  }

  Future<void> _attiva() async {
    setState(() {
      _loading = true;
      _errore = '';
    });
    final socio = await ClubService.socioPerCodice(_codice.text);
    if (socio == null) {
      setState(() {
        _errore = 'Codice non trovato. Controlla col presidente.';
        _loading = false;
      });
      return;
    }
    if (socio.attivo) {
      setState(() {
        _errore = 'Tesserino già attivato: usa ACCEDI.';
        _loading = false;
      });
      return;
    }
    if (_password.text.length < 6) {
      setState(() {
        _errore = 'La password deve avere almeno 6 caratteri.';
        _loading = false;
      });
      return;
    }
    if (_password.text != _conferma.text) {
      setState(() {
        _errore = 'Le password non coincidono.';
        _loading = false;
      });
      return;
    }
    await ClubService.aggiornaSocio(socio.id, attivo: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggato', true);
    await prefs.setBool('attivo', true);
    await prefs.setString('nome', '${socio.nome} ${socio.cognome}');
    await prefs.setString('email', socio.email);
    await prefs.setString('socioId', socio.id);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nero,
      appBar: AppBar(
        backgroundColor: AppTheme.nero,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.oro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ATTIVA TESSERINO', style: AppTheme.titoloMedio),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.badge, color: AppTheme.oro, size: 60),
            const SizedBox(height: 16),
            const Text('Inserisci il codice ricevuto dal presidente della Sede 303 CFI.',
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 14)),
            const SizedBox(height: 30),
            TextField(
              controller: _codice,
              style: const TextStyle(color: AppTheme.bianco, fontSize: 18, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: 'CFI303-XXXX',
                hintStyle: const TextStyle(color: AppTheme.grigio),
                filled: true,
                fillColor: AppTheme.neroCard,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.oro)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              style: const TextStyle(color: AppTheme.bianco),
              decoration: InputDecoration(
                hintText: 'Crea la tua password',
                hintStyle: const TextStyle(color: AppTheme.grigio),
                filled: true,
                fillColor: AppTheme.neroCard,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.oro)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _conferma,
              obscureText: true,
              style: const TextStyle(color: AppTheme.bianco),
              decoration: InputDecoration(
                hintText: 'Conferma password',
                hintStyle: const TextStyle(color: AppTheme.grigio),
                filled: true,
                fillColor: AppTheme.neroCard,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.oro)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_errore.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errore, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _attiva,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.oro,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('ATTIVA IL MIO TESSERINO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 24),
            const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
