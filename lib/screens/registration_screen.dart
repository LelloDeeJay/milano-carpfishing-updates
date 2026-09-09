import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import 'payment_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _cognome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _conferma = TextEditingController();
  final TextEditingController _luogoNascita = TextEditingController();
  final TextEditingController _indirizzo = TextEditingController();
  final TextEditingController _citta = TextEditingController();
  final TextEditingController _cap = TextEditingController();
  final TextEditingController _cf = TextEditingController();
  String _dataNascita = '';
  bool _privacy = false;
  bool _loading = false;
  String _errore = '';
  String? _fotoPath;

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _email.dispose();
    _password.dispose();
    _conferma.dispose();
    _luogoNascita.dispose();
    _indirizzo.dispose();
    _citta.dispose();
    _cap.dispose();
    _cf.dispose();
    super.dispose();
  }

  Future<void> _scegliData() async {
    final scelta = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1930, 1, 1),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.oro),
        ),
        child: child!,
      ),
    );
    if (scelta != null) {
      setState(() => _dataNascita =
          '${scelta.day.toString().padLeft(2, '0')}/${scelta.month.toString().padLeft(2, '0')}/${scelta.year}');
    }
  }

  Future<void> _scattaFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto != null) setState(() => _fotoPath = foto.path);
  }

  Future<void> _invia() async {
    setState(() {
      _loading = true;
      _errore = '';
    });
    if (_nome.text.trim().isEmpty || _cognome.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() { _errore = 'Compila nome, cognome ed email.'; _loading = false; });
      return;
    }
    if (_dataNascita.isEmpty || _luogoNascita.text.trim().isEmpty || _indirizzo.text.trim().isEmpty) {
      setState(() { _errore = 'Compila data di nascita, luogo di nascita e indirizzo.'; _loading = false; });
      return;
    }
    if (_citta.text.trim().isEmpty) {
      setState(() { _errore = 'Inserisci la città di residenza.'; _loading = false; });
      return;
    }
    if (_cap.text.trim().length != 5) {
      setState(() { _errore = 'Il CAP deve essere di 5 cifre.'; _loading = false; });
      return;
    }
    if (_cf.text.trim().length != 16) {
      setState(() { _errore = 'Il codice fiscale deve essere di 16 caratteri.'; _loading = false; });
      return;
    }
    if (_password.text.length < 6) {
      setState(() { _errore = 'La password deve avere almeno 6 caratteri.'; _loading = false; });
      return;
    }
    if (_password.text != _conferma.text) {
      setState(() { _errore = 'Le password non coincidono.'; _loading = false; });
      return;
    }
    if (!_privacy) {
      setState(() { _errore = 'Devi accettare la privacy per iscriverti.'; _loading = false; });
      return;
    }
    final socio = await ClubService.registraNuovoSocio(
      nome: _nome.text.trim(),
      cognome: _cognome.text.trim(),
      email: _email.text.trim(),
      dataNascita: _dataNascita,
      luogoNascita: _luogoNascita.text.trim(),
      indirizzo: _indirizzo.text.trim(),
      citta: _citta.text.trim(),
      cap: _cap.text.trim(),
      codiceFiscale: _cf.text.trim().toUpperCase(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggato', true);
    await prefs.setBool('attivo', false);
    await prefs.setString('nome', '${socio.nome} ${socio.cognome}');
    await prefs.setString('email', socio.email);
    await prefs.setString('socioId', socio.id);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          importo: socio.quota,
          causale: 'Quota iscrizione ${socio.nome} ${socio.cognome}',
          socioId: socio.id,
        ),
      ),
    );
  }

  InputDecoration _campo(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.grigio),
        filled: true,
        fillColor: AppTheme.neroCard,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.oro)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

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
        title: const Text('ISCRIVITI AL CLUB', style: AppTheme.titoloMedio),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _scattaFoto,
              child: Center(
                child: Container(
                  width: 110,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.oro, width: 2),
                  ),
                  child: _fotoPath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: AppTheme.oro, size: 36),
                            SizedBox(height: 6),
                            Text('FOTO', style: TextStyle(color: AppTheme.oro, fontSize: 12)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_fotoPath!), fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text('La foto si ritaglia e si centra da sola nel tesserino',
                textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
            const SizedBox(height: 20),
            TextField(controller: _nome, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Nome')),
            const SizedBox(height: 12),
            TextField(controller: _cognome, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Cognome')),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _dataNascita),
              readOnly: true,
              onTap: _scegliData,
              style: const TextStyle(color: AppTheme.bianco),
              decoration: _campo('Data di nascita (tocca per scegliere)'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _luogoNascita, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Luogo di nascita')),
            const SizedBox(height: 12),
            TextField(controller: _indirizzo, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Indirizzo')),
            const SizedBox(height: 12),
            TextField(controller: _citta, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Città di residenza')),
            const SizedBox(height: 12),
            TextField(controller: _cap, keyboardType: TextInputType.number, maxLength: 5, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('CAP')),
            const SizedBox(height: 12),
            TextField(controller: _cf, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Codice fiscale')),
            const SizedBox(height: 12),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Email')),
            const SizedBox(height: 12),
            TextField(controller: _password, obscureText: true, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Password (min 6 caratteri)')),
            const SizedBox(height: 12),
            TextField(controller: _conferma, obscureText: true, style: const TextStyle(color: AppTheme.bianco), decoration: _campo('Conferma password')),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _privacy,
                  checkColor: Colors.black,
                  activeColor: AppTheme.oro,
                  onChanged: (v) => setState(() => _privacy = v ?? false),
                ),
                Expanded(
                  child: Text(
                    'Accetto il trattamento dei dati personali (GDPR) ai fini della tessera sociale.',
                    style: TextStyle(color: AppTheme.grigio, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_errore.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errore, style: const TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _invia,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.oro,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('INVIA ISCRIZIONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 20),
            const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
