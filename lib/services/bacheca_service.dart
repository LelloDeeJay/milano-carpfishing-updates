import 'package:cloud_firestore/cloud_firestore.dart';

class Avviso {
  final String id;
  final String titolo;
  final String testo;
  final String data;

  Avviso({required this.id, required this.titolo, required this.testo, required this.data});

  Map<String, dynamic> toJson() => {'id': id, 'titolo': titolo, 'testo': testo, 'data': data};

  factory Avviso.fromJson(Map<String, dynamic> j) => Avviso(
        id: j['id'] ?? '', titolo: j['titolo'] ?? '',
        testo: j['testo'] ?? '', data: j['data'] ?? '',
      );
}

class Documento {
  final String id;
  final String nome;
  final String descrizione;
  final String data;

  Documento({required this.id, required this.nome, required this.descrizione, required this.data});

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'descrizione': descrizione, 'data': data};

  factory Documento.fromJson(Map<String, dynamic> j) => Documento(
        id: j['id'] ?? '', nome: j['nome'] ?? '',
        descrizione: j['descrizione'] ?? '', data: j['data'] ?? '',
      );
}

class BachecaService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String _oggi() {
    final o = DateTime.now();
    return '${o.day.toString().padLeft(2, '0')}/${o.month.toString().padLeft(2, '0')}/${o.year}';
  }

  static Future<List<Avviso>> getAvvisi() async {
    final snap = await _db.collection('avvisi').orderBy('id', descending: true).get();
    return snap.docs.map((d) => Avviso.fromJson(d.data())).toList();
  }

  static Future<void> pubblicaAvviso({required String titolo, required String testo}) async {
    final a = Avviso(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titolo: titolo, testo: testo, data: _oggi(),
    );
    await _db.collection('avvisi').doc(a.id).set(a.toJson());
  }

  static Future<List<Documento>> getDocumenti() async {
    final snap = await _db.collection('documenti').orderBy('id', descending: true).get();
    return snap.docs.map((d) => Documento.fromJson(d.data())).toList();
  }

  static Future<void> aggiungiDocumento({required String nome, required String descrizione}) async {
    final d = Documento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome, descrizione: descrizione, data: _oggi(),
    );
    await _db.collection('documenti').doc(d.id).set(d.toJson());
  }
}
