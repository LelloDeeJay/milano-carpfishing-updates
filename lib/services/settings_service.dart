import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _temaKey = 'tema_chiaro';
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Future<bool> isTemaChiaro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_temaKey) ?? false;
  }

  static Future<void> setTemaChiaro(bool chiaro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_temaKey, chiaro);
  }

  static Future<String?> getLogoBase64() async {
    final doc = await _db.collection('config').doc('logo').get();
    if (!doc.exists) return null;
    return doc.data()?['base64'] as String?;
  }

  static Future<void> salvaLogoBase64(String b64) async {
    await _db.collection('config').doc('logo').set({
      'base64': b64,
      'aggiornato': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, String>>> getRoadmap() async {
    final doc = await _db.collection('config').doc('roadmap').get();
    if (!doc.exists) {
      final base = [
        {'titolo': 'Chat del club in tempo reale', 'stato': 'in sviluppo'},
        {'titolo': 'Pagamento quote con Stripe', 'stato': 'pianificato'},
        {'titolo': 'Export PDF tesserino per stampa', 'stato': 'pianificato'},
        {'titolo': 'Classifiche e punteggi gare', 'stato': 'pianificato'},
      ];
      await salvaRoadmap(base);
      return base;
    }
    final lista = (doc.data()?['items'] as List<dynamic>?) ?? [];
    return lista.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<void> salvaRoadmap(List<Map<String, String>> items) async {
    await _db.collection('config').doc('roadmap').set({'items': items});
  }
}
