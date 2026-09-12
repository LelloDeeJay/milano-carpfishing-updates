import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/club_service.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';
import 'activation_screen.dart';
import 'admin_screen.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String _errore = '';
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _accedi() async {
    setState(() {
      _loading = true;
      _errore = '';
    });
    final email = _email.text.trim();
    final pass = _password.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _errore = 'Inserisci email e password.';
        _loading = false;
      });
      return;
    }
    final soci = await ClubService.getSoci();
    Socio? trovato;
    for (final s in soci) {
      if (s.email.toLowerCase() == email.toLowerCase() && s.attivo) trovato = s;
    }
    if (trovato == null) {
      setState(() {
        _errore = 'Socio non trovato o non attivo: iscriviti o attiva col codice.';
        _loading = false;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggato', true);
    await prefs.setBool('attivo', true);
    await prefs.setString('nome', '${trovato.nome} ${trovato.cognome}');
    await prefs.setString('email', trovato.email);
    await prefs.setString('socioId', trovato.id);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> _areaPresidente() async {
    final pin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('AREA PRESIDENTE', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: AppTheme.bianco, fontSize: 20, letterSpacing: 4),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'PIN',
                hintStyle: TextStyle(color: AppTheme.grigio),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final conferma = await showDialog<bool>(
                    context: ctx,
                    builder: (c2) => AlertDialog(
                      backgroundColor: AppTheme.neroCard,
                      title: const Text('PIN DIMENTICATO?', style: AppTheme.titoloMedio),
                      content: const Text('Il PIN verrà ripristinato al default. Dovrai cambiarlo al prossimo accesso.', style: TextStyle(color: AppTheme.bianco)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
                        TextButton(onPressed: () => Navigator.pop(c2, true), child: const Text('RIPRISTINA', style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (conferma == true) {
                    await PinService.resettaPinDefault();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN ripristinato al default'), backgroundColor: AppTheme.verde));
                    Navigator.pop(ctx, false);
                  }
                },
                child: const Text('PIN dimenticato?', style: TextStyle(color: AppTheme.oro, fontSize: 12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ENTRA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (ok != true) return;
    if (await PinService.verificaPin(pin.text)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggato', true);
      await prefs.setBool('admin', true);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN errato'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nero,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Text('LA NUOVA MILANO', style: AppTheme.titoloMedio, textAlign: TextAlign.center),
              const Text('CARPFISHING', style: AppTheme.titoloGrande, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Sede 303 CFI', style: AppTheme.sottotitolo, textAlign: TextAlign.center),
              const SizedBox(height: 36),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.bianco),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: AppTheme.grigio),
                  filled: true,
                  fillColor: AppTheme.neroCard,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.oro)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: true,
                style: const TextStyle(color: AppTheme.bianco),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: AppTheme.grigio),
                  filled: true,
                  fillColor: AppTheme.neroCard,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppTheme.oro)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (_errore.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errore, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                ),
              ElevatedButton(
                onPressed: _loading ? null : _accedi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.oro,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('ACCEDI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.oroScuro)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OPPURE', style: TextStyle(color: AppTheme.oroChiaro, fontSize: 13))),
                  Expanded(child: Divider(color: AppTheme.oroScuro)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen())),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('ISCRIVITI AL CLUB', style: TextStyle(color: AppTheme.oro, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivationScreen())),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.verde), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('ATTIVA TESSERINO', style: TextStyle(color: AppTheme.verde, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _areaPresidente,
                child: const Text('Area presidente', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
              ),
              const SizedBox(height: 12),
              const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
