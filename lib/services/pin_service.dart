import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio per la gestione del PIN del presidente.
/// Il PIN viene salvato sia localmente (SharedPreferences) sia su Firebase.
/// Il PIN default è 3030, ma il presidente può cambiarlo in qualsiasi momento.
class PinService {
  static const String _pinDefault = '3030';
  static const String _pinKeyLocal = 'pin_presidente';
  static const String _pinDocCloud = 'pin';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Verifica se il PIN inserito è corretto.
  /// Controlla prima il PIN salvato dall'utente, poi il default.
  static Future<bool> verificaPin(String pinInserito) async {
    final pinSalvato = await _getPinSalvato();
    return pinInserito == pinSalvato;
  }

  /// Cambia il PIN del presidente.
  /// Salva sia localmente sia su Firebase.
  static Future<void> cambiaPin(String nuovoPin) async {
    // Salva localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKeyLocal, nuovoPin);

    // Salva su Firebase
    await _db.collection('config').doc(_pinDocCloud).set({
      'pin': nuovoPin,
      'aggiornato': DateTime.now().toIso8601String(),
    });
  }

  /// Resetta il PIN al default (3030).
  /// Usato quando il presidente dimentica il PIN.
  static Future<void> resettaPinDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKeyLocal);

    try {
      await _db.collection('config').doc(_pinDocCloud).delete();
    } catch (e) {
      // Se non esiste, non fa nulla
    }
  }

  /// Restituisce il PIN attuale salvato dall'utente, oppure il default.
  static Future<String> _getPinSalvato() async {
    // Prova locale
    final prefs = await SharedPreferences.getInstance();
    final pinLocal = prefs.getString(_pinKeyLocal);
    if (pinLocal != null && pinLocal.isNotEmpty) return pinLocal;

    // Prova cloud
    try {
      final doc = await _db.collection('config').doc(_pinDocCloud).get();
      if (doc.exists) {
        final pinCloud = doc.data()?['pin'] as String?;
        if (pinCloud != null && pinCloud.isNotEmpty) {
          // Salva anche localmente per velocizzare
          await prefs.setString(_pinKeyLocal, pinCloud);
          return pinCloud;
        }
      }
    } catch (e) {
      // Cloud non raggiungibile: usa default
    }

    return _pinDefault;
  }

  /// Restituisce true se il PIN è stato personalizzato (diverso dal default).
  static Future<bool> pinPersonalizzato() async {
    final pin = await _getPinSalvato();
    return pin != _pinDefault;
  }
}
