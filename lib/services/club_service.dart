import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Socio {
  final String id;
  final String nome;
  final String cognome;
  final String email;
  final String dataNascita;
  final String luogoNascita;
  final String indirizzo;
  final String citta;
  final String cap;
  final String codiceFiscale;
  final String numeroTessera;
  final String codiceAttivazione;
  final bool attivo;
  final bool quotaPagata;
  final String scadenzaQuota;
  final String tipoIscrizione;
  final double quota;
  final String ruolo;

  Socio({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    this.dataNascita = '',
    this.luogoNascita = '',
    this.indirizzo = '',
    this.citta = '',
    this.cap = '',
    this.codiceFiscale = '',
    required this.numeroTessera,
    required this.codiceAttivazione,
    this.attivo = false,
    this.quotaPagata = false,
    required this.scadenzaQuota,
    required this.tipoIscrizione,
    required this.quota,
    this.ruolo = 'socio',
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'nome': nome, 'cognome': cognome, 'email': email,
        'dataNascita': dataNascita, 'luogoNascita': luogoNascita,
        'indirizzo': indirizzo, 'citta': citta, 'cap': cap,
        'codiceFiscale': codiceFiscale,
        'numeroTessera': numeroTessera, 'codiceAttivazione': codiceAttivazione,
        'attivo': attivo, 'quotaPagata': quotaPagata,
        'scadenzaQuota': scadenzaQuota, 'tipoIscrizione': tipoIscrizione,
        'quota': quota, 'ruolo': ruolo,
      };

  factory Socio.fromJson(Map<String, dynamic> j) => Socio(
        id: j['id'] ?? '', nome: j['nome'] ?? '', cognome: j['cognome'] ?? '',
        email: j['email'] ?? '', dataNascita: j['dataNascita'] ?? '',
        luogoNascita: j['luogoNascita'] ?? '', indirizzo: j['indirizzo'] ?? '',
        citta: j['citta'] ?? '', cap: j['cap'] ?? '',
        codiceFiscale: j['codiceFiscale'] ?? '',
        numeroTessera: j['numeroTessera'] ?? '',
        codiceAttivazione: j['codiceAttivazione'] ?? '',
        attivo: j['attivo'] ?? false, quotaPagata: j['quotaPagata'] ?? false,
        scadenzaQuota: j['scadenzaQuota'] ?? '',
        tipoIscrizione: j['tipoIscrizione'] ?? '',
        quota: (j['quota'] ?? 0).toDouble(),
        ruolo: j['ruolo'] ?? 'socio',
      );
}

class DatiPagamento {
  final String iban;
  final String bic;
  final String intestatario;
  final String contoPostale;
  final String intestatarioPostale;

  DatiPagamento({
    this.iban = '', this.bic = '', this.intestatario = '',
    this.contoPostale = '', this.intestatarioPostale = '',
  });

  Map<String, dynamic> toJson() => {
        'iban': iban, 'bic': bic, 'intestatario': intestatario,
        'contoPostale': contoPostale, 'intestatarioPostale': intestatarioPostale,
      };

  factory DatiPagamento.fromJson(Map<String, dynamic> j) => DatiPagamento(
        iban: j['iban'] ?? '', bic: j['bic'] ?? '',
        intestatario: j['intestatario'] ?? '',
        contoPostale: j['contoPostale'] ?? '',
        intestatarioPostale: j['intestatarioPostale'] ?? '',
      );
}

class Evento {
  final String id;
  final String nome;
  final String luogo;
  final String data;
  final double lat;
  final double lng;
  final String tipo;
  final List<String> partecipanti;

  Evento({
    required this.id,
    required this.nome,
    required this.luogo,
    required this.data,
    required this.lat,
    required this.lng,
    this.tipo = 'gara',
    this.partecipanti = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'nome': nome, 'luogo': luogo, 'data': data,
        'lat': lat, 'lng': lng, 'tipo': tipo, 'partecipanti': partecipanti,
      };

  factory Evento.fromJson(Map<String, dynamic> j) => Evento(
        id: j['id'] ?? '', nome: j['nome'] ?? '', luogo: j['luogo'] ?? '',
        data: j['data'] ?? '', lat: (j['lat'] ?? 0).toDouble(),
        lng: (j['lng'] ?? 0).toDouble(), tipo: j['tipo'] ?? 'gara',
        partecipanti: (j['partecipanti'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}

class ClubService {
  static const double defaultAlta = 50.0;
  static const double defaultBassa = 30.0;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<String> nomiMesi = [
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  ];

  static String scadenzaAnnoCorrente() => '${DateTime.now().year}-12-31';

  static Map<int, double> _quoteDefault() {
    final m = <int, double>{};
    for (var i = 1; i <= 12; i++) {
      m[i] = i >= 10 ? defaultBassa : defaultAlta;
    }
    return m;
  }

  static Future<void> inizializzaFondatori() async {
    final check = await _db.collection('soci').limit(1).get();
    if (check.docs.isNotEmpty) return;
    final fondatori = [
      {'nome': 'Alessandro', 'cognome': 'Presidente', 'ruolo': 'presidente'},
      {'nome': 'Luca', 'cognome': 'Vice Presidente', 'ruolo': 'vice'},
      {'nome': 'Elvio', 'cognome': 'Segretario', 'ruolo': 'segretario'},
    ];
    final batch = _db.batch();
    var prog = 0;
    for (final f in fondatori) {
      prog++;
      final s = Socio(
        id: 'fondatore_$prog',
        nome: f['nome']!,
        cognome: f['cognome']!,
        email: '${f['nome']!.toLowerCase()}@sede303.it',
        numeroTessera: prog.toString().padLeft(4, '0'),
        codiceAttivazione: _generaCodice(),
        attivo: true,
        quotaPagata: true,
        scadenzaQuota: scadenzaAnnoCorrente(),
        tipoIscrizione: 'fondatore',
        quota: defaultAlta,
        ruolo: f['ruolo']!,
      );
      batch.set(_db.collection('soci').doc(s.id), s.toJson());
    }
    batch.set(_db.collection('config').doc('progressivo'), {'value': prog});
    await batch.commit();
    final evCheck = await _db.collection('eventi').limit(1).get();
    if (evCheck.docs.isEmpty) {
      final b2 = _db.batch();
      final demo = [
        Evento(id: 'ev1', nome: 'Gara di Autunno', luogo: 'Lago di Como', data: '15/10/2026', lat: 45.986, lng: 9.227),
        Evento(id: 'ev2', nome: 'Trofeo Carpa Oro', luogo: 'Lago Maggiore', data: '09/11/2026', lat: 45.855, lng: 8.652),
      ];
      for (final e in demo) {
        b2.set(_db.collection('eventi').doc(e.id), e.toJson());
      }
      await b2.commit();
    }
  }

  static Future<Map<int, double>> getQuote() async {
    final doc = await _db.collection('config').doc('quote').get();
    final base = _quoteDefault();
    if (doc.exists) {
      (doc.data() ?? {}).forEach((k, v) {
        final m = int.tryParse(k);
        if (m != null && v is num) base[m] = v.toDouble();
      });
    }
    return base;
  }

  static Future<void> salvaQuote(Map<int, double> quote) async {
    final mappa = <String, double>{};
    quote.forEach((k, v) => mappa['$k'] = v);
    await _db.collection('config').doc('quote').set(mappa);
  }

  static Future<double> quotaPerMeseCorrente() async {
    final quote = await getQuote();
    return quote[DateTime.now().month] ?? defaultAlta;
  }

  static Future<List<Socio>> getSoci() async {
    final snap = await _db.collection('soci').get();
    return snap.docs.map((d) => Socio.fromJson(d.data())).toList();
  }

  static Future<List<Evento>> getEventi() async {
    final snap = await _db.collection('eventi').get();
    return snap.docs.map((d) => Evento.fromJson(d.data())).toList();
  }

  static Future<void> creaEvento({
    required String nome,
    required String luogo,
    required String data,
    required double lat,
    required double lng,
    String tipo = 'gara',
  }) async {
    final e = Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome, luogo: luogo, data: data, lat: lat, lng: lng, tipo: tipo,
    );
    await _db.collection('eventi').doc(e.id).set(e.toJson());
  }

  static Future<void> aderisciEvento(String eventoId, String socioId) async {
    await _db.collection('eventi').doc(eventoId).update({
      'partecipanti': FieldValue.arrayUnion([socioId]),
    });
  }

  static Future<void> salvaDatiPagamento(DatiPagamento d) async {
    await _db.collection('config').doc('pagamento').set(d.toJson());
  }

  static Future<DatiPagamento> getDatiPagamento() async {
    final doc = await _db.collection('config').doc('pagamento').get();
    if (!doc.exists) return DatiPagamento();
    return DatiPagamento.fromJson(doc.data() ?? {});
  }

  static String qrBonificoSepa(DatiPagamento d, double importo, String causale) {
    final b = StringBuffer();
    b.writeln('BCD');
    b.writeln('001');
    b.writeln('1');
    b.writeln('SCT');
    b.writeln(d.bic);
    b.writeln(d.intestatario);
    b.writeln(d.iban);
    b.writeln('EUR${importo.toStringAsFixed(2)}');
    b.writeln('');
    b.write(causale);
    return b.toString();
  }

  static String qrBollettino(DatiPagamento d, double importo, String causale) {
    return 'BOLLETTINO POSTALE\nConto: ${d.contoPostale}\nIntestatario: ${d.intestatarioPostale}\nImporto: EUR ${importo.toStringAsFixed(2)}\nCausale: $causale';
  }

  static String _generaCodice() {
    const caratteri = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final parte = List.generate(4, (_) => caratteri[rnd.nextInt(caratteri.length)]).join();
    return 'CFI303-$parte';
  }

  static Future<int> _nextProgressivo() async {
    final ref = _db.collection('config').doc('progressivo');
    return _db.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? ((snap.data()?['value'] as num?) ?? 0).toInt() : 0;
      final next = current + 1;
      tx.set(ref, {'value': next});
      return next;
    });
  }

  static Future<Socio> aggiungiSocioManuale({
    required String nome, required String cognome, required String email,
    String dataNascita = '', String luogoNascita = '',
    String indirizzo = '', String citta = '', String cap = '',
    String codiceFiscale = '', String ruolo = 'socio',
  }) async {
    final prog = await _nextProgressivo();
    final nuovo = Socio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome, cognome: cognome, email: email,
      dataNascita: dataNascita, luogoNascita: luogoNascita,
      indirizzo: indirizzo, citta: citta, cap: cap,
      codiceFiscale: codiceFiscale,
      numeroTessera: prog.toString().padLeft(4, '0'),
      codiceAttivazione: _generaCodice(),
      scadenzaQuota: scadenzaAnnoCorrente(),
      tipoIscrizione: 'manuale',
      quota: await quotaPerMeseCorrente(),
      ruolo: ruolo,
    );
    await _db.collection('soci').doc(nuovo.id).set(nuovo.toJson());
    return nuovo;
  }

  static Future<Socio> registraNuovoSocio({
    required String nome, required String cognome, required String email,
    String dataNascita = '', String luogoNascita = '',
    String indirizzo = '', String citta = '', String cap = '',
    String codiceFiscale = '',
  }) async {
    final prog = await _nextProgressivo();
    final nuovo = Socio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome, cognome: cognome, email: email,
      dataNascita: dataNascita, luogoNascita: luogoNascita,
      indirizzo: indirizzo, citta: citta, cap: cap,
      codiceFiscale: codiceFiscale,
      numeroTessera: prog.toString().padLeft(4, '0'),
      codiceAttivazione: _generaCodice(),
      scadenzaQuota: scadenzaAnnoCorrente(),
      tipoIscrizione: 'app',
      quota: await quotaPerMeseCorrente(),
    );
    await _db.collection('soci').doc(nuovo.id).set(nuovo.toJson());
    return nuovo;
  }

  static Future<Socio?> socioPerCodice(String codice) async {
    final snap = await _db.collection('soci')
        .where('codiceAttivazione', isEqualTo: codice.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Socio.fromJson(snap.docs.first.data());
  }

  static Future<void> aggiornaSocio(String id, {bool? attivo, bool? quotaPagata}) async {
    final mappa = <String, dynamic>{};
    if (attivo != null) mappa['attivo'] = attivo;
    if (quotaPagata != null) mappa['quotaPagata'] = quotaPagata;
    if (mappa.isEmpty) return;
    await _db.collection('soci').doc(id).update(mappa);
  }


  static Future<String> rigeneraCodiceAttivazione(String id) async {
    final nuovoCodice = _generaCodice();
    await _db.collection('soci').doc(id).update({'codiceAttivazione': nuovoCodice});
    return nuovoCodice;
  }
  static Future<void> rimuoviSocio(String id) async {
    await _db.collection('soci').doc(id).delete();
  }
}
