import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/bacheca_service.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Socio> _soci = [];
  final TextEditingController _iban = TextEditingController();
  final TextEditingController _bic = TextEditingController();
  final TextEditingController _intestatario = TextEditingController();
  final TextEditingController _contoPostale = TextEditingController();
  final TextEditingController _intestatarioPostale = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carica();
  }

  @override
  void dispose() {
    _iban.dispose();
    _bic.dispose();
    _intestatario.dispose();
    _contoPostale.dispose();
    _intestatarioPostale.dispose();
    super.dispose();
  }

  Future<void> _carica() async {
    final soci = await ClubService.getSoci();
    final dati = await ClubService.getDatiPagamento();
    if (!mounted) return;
    setState(() {
      _soci = soci;
      _iban.text = dati.iban;
      _bic.text = dati.bic;
      _intestatario.text = dati.intestatario;
      _contoPostale.text = dati.contoPostale;
      _intestatarioPostale.text = dati.intestatarioPostale;
    });
  }

  Future<void> _gestisciQuote() async {
    try {
      final quote = await ClubService.getQuote();
      if (!mounted) return;
      final controllers = <int, TextEditingController>{};
      for (var i = 1; i <= 12; i++) {
        controllers[i] = TextEditingController(text: (quote[i] ?? ClubService.defaultAlta).toStringAsFixed(0));
      }
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.neroCard,
          title: const Text('QUOTE PER MESE', style: AppTheme.titoloMedio),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var i = 1; i <= 12; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 95, child: Text(ClubService.nomiMesi[i - 1], style: const TextStyle(color: AppTheme.bianco, fontSize: 14))),
                        Expanded(
                          child: TextField(
                            controller: controllers[i],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppTheme.bianco),
                            decoration: const InputDecoration(suffixText: 'EUR', filled: true, fillColor: AppTheme.nero, isDense: true),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SALVA', style: TextStyle(color: AppTheme.oro))),
          ],
        ),
      );
      if (ok != true) return;
      final nuove = <int, double>{};
      controllers.forEach((k, c) { nuove[k] = double.tryParse(c.text.trim()) ?? 0; });
      await ClubService.salvaQuote(nuove);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote salvate'), backgroundColor: AppTheme.verde));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _nuovoSocio() async {
    final nome = TextEditingController();
    final cognome = TextEditingController();
    final email = TextEditingController();
    final dataNascita = TextEditingController();
    final luogoNascita = TextEditingController();
    final indirizzo = TextEditingController();
    final citta = TextEditingController();
    final cap = TextEditingController();
    final cf = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('MODULO NUOVO SOCIO', style: AppTheme.titoloMedio),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nome, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Nome')),
                const SizedBox(height: 8),
                TextField(controller: cognome, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Cognome')),
                const SizedBox(height: 8),
                TextField(controller: email, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: dataNascita, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Data di nascita (gg/mm/aaaa)')),
                const SizedBox(height: 8),
                TextField(controller: luogoNascita, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Luogo di nascita')),
                const SizedBox(height: 8),
                TextField(controller: indirizzo, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Indirizzo')),
                const SizedBox(height: 8),
                TextField(controller: citta, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Citta di residenza')),
                const SizedBox(height: 8),
                TextField(controller: cap, keyboardType: TextInputType.number, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'CAP')),
                const SizedBox(height: 8),
                TextField(controller: cf, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Codice fiscale')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CREA TESSERA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (ok != true || nome.text.trim().isEmpty || cognome.text.trim().isEmpty) return;
    final nuovo = await ClubService.aggiungiSocioManuale(
      nome: nome.text.trim(),
      cognome: cognome.text.trim(),
      email: email.text.trim(),
      dataNascita: dataNascita.text.trim(),
      luogoNascita: luogoNascita.text.trim(),
      indirizzo: indirizzo.text.trim(),
      citta: citta.text.trim(),
      cap: cap.text.trim(),
      codiceFiscale: cf.text.trim().toUpperCase(),
    );
    await _carica();
    if (!mounted) return;
    _mostraCodiceAttivazione(nuovo);
  }

  void _mostraCodiceAttivazione(Socio s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('TESSERA CREATA', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${s.nome} ${s.cognome} - Tessera N. ${s.numeroTessera}', style: const TextStyle(color: AppTheme.bianco), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: AppTheme.nero, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.oro, width: 2)),
              child: SelectableText(s.codiceAttivazione, style: const TextStyle(color: AppTheme.oro, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 14),
            const Text('Comunica questo codice al socio: lo usa per attivare il tesserino sul suo telefono.', style: TextStyle(color: AppTheme.grigio, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CHIUDI', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
  }

  void _mostraTessera(Socio s) {
    final qrData = 'CFI303|${s.numeroTessera}|${s.nome} ${s.cognome}|${s.codiceFiscale}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.neroCard,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppTheme.neroCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.oro, width: 3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('LA NUOVA MILANO CARPFISHING A.S.D.', style: AppTheme.sottotitolo, textAlign: TextAlign.center),
              const Text('Sede 303 CFI', style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
              const SizedBox(height: 14),
              Text('${s.nome} ${s.cognome}', style: AppTheme.titoloMedio),
              Text('N ${s.numeroTessera}', style: const TextStyle(color: AppTheme.bianco, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: s.attivo ? AppTheme.verde : Colors.orange, borderRadius: BorderRadius.circular(12)),
                child: Text(s.attivo ? 'SOCIO ATTIVO' : 'DA ATTIVARE', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),
              Container(color: Colors.white, padding: const EdgeInsets.all(6), child: QrImageView(data: qrData, size: 130, backgroundColor: Colors.white)),
              const SizedBox(height: 10),
              Text('VALIDO FINO AL ${s.scadenzaQuota}', style: const TextStyle(color: AppTheme.oroChiaro, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CHIUDI', style: TextStyle(color: AppTheme.oro))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _modificaDatiSocio(Socio s) async {
    final nomeCtrl = TextEditingController(text: s.nome);
    final cognomeCtrl = TextEditingController(text: s.cognome);
    final emailCtrl = TextEditingController(text: s.email);
    final dataNascitaCtrl = TextEditingController(text: s.dataNascita);
    final luogoNascitaCtrl = TextEditingController(text: s.luogoNascita);
    final indirizzoCtrl = TextEditingController(text: s.indirizzo);
    final cittaCtrl = TextEditingController(text: s.citta);
    final capCtrl = TextEditingController(text: s.cap);
    final cfCtrl = TextEditingController(text: s.codiceFiscale);

    final salvato = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('MODIFICA DATI SOCIO', style: AppTheme.titoloMedio),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Nome', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: cognomeCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Cognome', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: emailCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: dataNascitaCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Data nascita (gg/mm/aaaa)', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: luogoNascitaCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Luogo nascita', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: indirizzoCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Indirizzo', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: cittaCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Citta', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: capCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'CAP', filled: true, fillColor: AppTheme.nero)),
              TextField(controller: cfCtrl, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(labelText: 'Codice Fiscale', filled: true, fillColor: AppTheme.nero)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SALVA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (salvato != true) return;
    await FirebaseFirestore.instance.collection('soci').doc(s.id).update({
      'nome': nomeCtrl.text.trim(),
      'cognome': cognomeCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'dataNascita': dataNascitaCtrl.text.trim(),
      'luogoNascita': luogoNascitaCtrl.text.trim(),
      'indirizzo': indirizzoCtrl.text.trim(),
      'citta': cittaCtrl.text.trim(),
      'cap': capCtrl.text.trim(),
      'codiceFiscale': cfCtrl.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati socio aggiornati'), backgroundColor: AppTheme.verde));
    await _carica();
  }

  Future<void> _eliminaSocio(Socio s) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (c2) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('ELIMINA SOCIO', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stai per eliminare DEFINITIVAMENTE:', style: const TextStyle(color: AppTheme.bianco)),
            const SizedBox(height: 8),
            Text('${s.nome} ${s.cognome}', style: const TextStyle(color: AppTheme.oro, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Tessera N. ${s.numeroTessera}', style: const TextStyle(color: AppTheme.grigio)),
            const SizedBox(height: 12),
            const Text('Questa azione NON puo essere annullata. Tutti i dati del socio verranno cancellati da Firebase.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(c2, true), child: const Text('ELIMINA', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (conferma != true) return;
    await ClubService.rimuoviSocio(s.id);
    await _carica();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.nome} ${s.cognome} eliminato'), backgroundColor: Colors.redAccent));
  }

  Future<void> _rigeneraCodice(Socio s) async {
    final confermato = await showDialog<bool>(
      context: context,
      builder: (c2) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('RIGENERA CODICE', style: AppTheme.titoloMedio),
        content: Text('Generare un nuovo codice di attivazione per ${s.nome} ${s.cognome}?\nIl vecchio codice verra invalidato.', style: const TextStyle(color: AppTheme.bianco)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(c2, true), child: const Text('RIGENERA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (confermato != true) return;
    final nuovo = await ClubService.rigeneraCodiceAttivazione(s.id);
    if (!mounted) return;
    await _carica();
    final socioAggiornato = _soci.firstWhere((x) => x.id == s.id, orElse: () => s);
    _mostraCodiceAttivazione(Socio(
      id: socioAggiornato.id, nome: socioAggiornato.nome, cognome: socioAggiornato.cognome, email: socioAggiornato.email,
      numeroTessera: socioAggiornato.numeroTessera, codiceAttivazione: nuovo,
      scadenzaQuota: socioAggiornato.scadenzaQuota, tipoIscrizione: socioAggiornato.tipoIscrizione, quota: socioAggiornato.quota,
    ));
  }

  Future<void> _dettaglioSocio(Socio s) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.neroCard,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${s.nome} ${s.cognome}', style: AppTheme.titoloMedio, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.nero, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.oro)),
                  child: Column(
                    children: [
                      const Text('CODICE DI ATTIVAZIONE', style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
                      const SizedBox(height: 4),
                      SelectableText(s.codiceAttivazione, style: const TextStyle(color: AppTheme.oro, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: s.codiceAttivazione));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Codice copiato'), backgroundColor: AppTheme.verde));
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('COPIA'),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), foregroundColor: AppTheme.oro),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Share.share(
                            'Codice di attivazione tesserino La Nuova Milano Carpfishing A.S.D.:\n\n${s.codiceAttivazione}\n\nNome: ${s.nome} ${s.cognome}\nTessera N. ${s.numeroTessera}\n\nUsa questo codice nell\'app per attivare il tuo tesserino.'
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('CONDIVIDI'),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), foregroundColor: AppTheme.oro),
                      ),
                    ),
                  ],
                ),
                if (!s.attivo) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _rigeneraCodice(s);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('RIGENERA CODICE'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), foregroundColor: Colors.orange),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Tessera N. ${s.numeroTessera}', style: const TextStyle(color: AppTheme.bianco)),
                Text('Nato: ${s.dataNascita} - ${s.luogoNascita}', style: const TextStyle(color: AppTheme.bianco, fontSize: 13)),
                Text('CF: ${s.codiceFiscale}', style: const TextStyle(color: AppTheme.bianco, fontSize: 13)),
                Text('Residenza: ${s.indirizzo}, ${s.citta} (${s.cap})', style: const TextStyle(color: AppTheme.bianco, fontSize: 13)),
                Text('Email: ${s.email}', style: const TextStyle(color: AppTheme.bianco, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: s.attivo ? AppTheme.verde.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(s.attivo ? 'ATTIVO' : 'DA ATTIVARE', textAlign: TextAlign.center, style: TextStyle(color: s.attivo ? AppTheme.verde : Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: s.quotaPagata ? AppTheme.verde.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(s.quotaPagata ? 'QUOTA OK' : 'QUOTA DA PAGARE', textAlign: TextAlign.center, style: TextStyle(color: s.quotaPagata ? AppTheme.verde : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _mostraTessera(s); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black),
                  child: const Text('MOSTRA TESSERA'),
                ),
                if (!s.attivo) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await ClubService.aggiornaSocio(s.id, attivo: true);
                      Navigator.pop(ctx);
                      await _carica();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, foregroundColor: Colors.white),
                    child: const Text('APPROVA / ATTIVA'),
                  ),
                ],
                if (!s.quotaPagata) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await ClubService.aggiornaSocio(s.id, quotaPagata: true);
                      Navigator.pop(ctx);
                      await _carica();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black),
                    child: const Text('SEGNA QUOTA PAGATA'),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _modificaDatiSocio(s); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text('MODIFICA DATI'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _eliminaSocio(s); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  child: const Text('ELIMINA SOCIO'),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CHIUDI', style: TextStyle(color: AppTheme.grigio))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pubblicaAvviso() async {
    final titolo = TextEditingController();
    final testo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('PUBBLICA IN BACHECA', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titolo, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Titolo avviso')),
            const SizedBox(height: 8),
            TextField(controller: testo, maxLines: 3, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Testo avviso')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('PUBBLICA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (ok != true || titolo.text.trim().isEmpty) return;
    await BachecaService.pubblicaAvviso(titolo: titolo.text.trim(), testo: testo.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avviso pubblicato in bacheca'), backgroundColor: AppTheme.verde));
  }

  Future<void> _aggiungiDocumento() async {
    final nome = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('AGGIUNGI DOCUMENTO', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nome, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Nome modulo (es. Iscrizione gara)')),
            const SizedBox(height: 8),
            TextField(controller: desc, maxLines: 2, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Descrizione')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('AGGIUNGI', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (ok != true || nome.text.trim().isEmpty) return;
    await BachecaService.aggiungiDocumento(nome: nome.text.trim(), descrizione: desc.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento aggiunto in segreteria'), backgroundColor: AppTheme.verde));
  }

  Future<void> _nuovaGara() async {
    final nome = TextEditingController();
    final luogo = TextEditingController();
    final data = TextEditingController();
    final lat = TextEditingController();
    final lng = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('NUOVA GARA', style: AppTheme.titoloMedio),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nome, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Nome gara')),
                const SizedBox(height: 8),
                TextField(controller: luogo, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Luogo')),
                const SizedBox(height: 8),
                TextField(controller: data, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Data (gg/mm/aaaa)')),
                const SizedBox(height: 8),
                TextField(controller: lat, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Latitudine (es. 45.986)')),
                const SizedBox(height: 8),
                TextField(controller: lng, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Longitudine (es. 9.227)')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA', style: TextStyle(color: AppTheme.grigio))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CREA GARA', style: TextStyle(color: AppTheme.oro))),
        ],
      ),
    );
    if (ok != true || nome.text.trim().isEmpty || luogo.text.trim().isEmpty || data.text.trim().isEmpty) return;
    await ClubService.creaEvento(
      nome: nome.text.trim(),
      luogo: luogo.text.trim(),
      data: data.text.trim(),
      lat: double.tryParse(lat.text.trim()) ?? 42.0,
      lng: double.tryParse(lng.text.trim()) ?? 12.0,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gara creata: la vedi sulla mappa'), backgroundColor: AppTheme.verde));
  }

  Future<void> _salvaPagamenti() async {
    await ClubService.salvaDatiPagamento(DatiPagamento(
      iban: _iban.text.trim().toUpperCase(),
      bic: _bic.text.trim().toUpperCase(),
      intestatario: _intestatario.text.trim(),
      contoPostale: _contoPostale.text.trim(),
      intestatarioPostale: _intestatarioPostale.text.trim(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati di pagamento salvati'), backgroundColor: AppTheme.verde));
  }

  @override
  Widget build(BuildContext context) {
    final attivi = _soci.where((s) => s.attivo).length;
    final inAttesa = _soci.where((s) => !s.attivo).length;
    final pagate = _soci.where((s) => s.quotaPagata).length;
    final richieste = _soci.where((s) => !s.attivo).toList();
    return Scaffold(
      backgroundColor: AppTheme.nero,
      appBar: AppBar(
        backgroundColor: AppTheme.nero,
        elevation: 0,
        title: const Text('PANNELLO PRESIDENTE', style: AppTheme.titoloMedio),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.oro),
            tooltip: 'Impostazioni',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppTheme.verde.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)), child: Text('ATTIVI: $attivi', textAlign: TextAlign.center, style: const TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 8),
              Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)), child: Text('ATTESA: $inAttesa', textAlign: TextAlign.center, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))),
              const SizedBox(width: 8),
              Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppTheme.oro.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)), child: Text('QUOTE: $pagate', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.oroChiaro, fontWeight: FontWeight.bold)))),
            ],
          ),
          if (richieste.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('RICHIESTE IN ATTESA (${richieste.length})', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Soci in attesa di attivazione. Tocca per generare il codice da comunicare al socio.', style: TextStyle(color: AppTheme.bianco, fontSize: 12)),
                  const SizedBox(height: 12),
                  ...richieste.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: AppTheme.neroCard, borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.person_add, color: Colors.white),
                      ),
                      title: Text('${s.nome} ${s.cognome}', style: const TextStyle(color: AppTheme.bianco, fontWeight: FontWeight.bold)),
                      subtitle: Text('N. ${s.numeroTessera} - ${s.email}', style: const TextStyle(color: AppTheme.grigio, fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                      onTap: () => _dettaglioSocio(s),
                    ),
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nuovoSocio,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('INSERISCI SOCIO ESISTENTE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _gestisciQuote,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('GESTISCI QUOTE', style: TextStyle(color: AppTheme.oro, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _pubblicaAvviso,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.verde), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('PUBBLICA IN BACHECA', style: TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _aggiungiDocumento,
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('AGGIUNGI DOCUMENTO', style: TextStyle(color: AppTheme.oro, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _nuovaGara,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('NUOVA GARA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          const Text('TUTTI I SOCI E TESSERE', style: AppTheme.titoloMedio),
          const SizedBox(height: 8),
          if (_soci.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Nessun socio inserito. Usa INSERISCI SOCIO ESISTENTE per creare la prima tessera.', style: TextStyle(color: AppTheme.grigio, fontSize: 13), textAlign: TextAlign.center),
            ),
          ..._soci.map((s) => Card(
            color: AppTheme.neroCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: s.attivo ? AppTheme.verde : Colors.orange, borderRadius: BorderRadius.circular(20)),
                child: Icon(s.attivo ? Icons.check : Icons.hourglass_empty, color: Colors.white, size: 20),
              ),
              title: Text('${s.nome} ${s.cognome}', style: const TextStyle(color: AppTheme.bianco)),
              subtitle: Text('N. ${s.numeroTessera} - ${s.attivo ? "ATTIVO" : "ATTESA"} - ${s.quotaPagata ? "QUOTA OK" : "QUOTA NO"}', style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
              onTap: () => _dettaglioSocio(s),
            ),
          )),
          const SizedBox(height: 24),
          const Text('DATI DI PAGAMENTO', style: AppTheme.titoloMedio),
          const SizedBox(height: 8),
          TextField(controller: _iban, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'IBAN', filled: true, fillColor: AppTheme.neroCard)),
          const SizedBox(height: 8),
          TextField(controller: _bic, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'BIC (facoltativo)', filled: true, fillColor: AppTheme.neroCard)),
          const SizedBox(height: 8),
          TextField(controller: _intestatario, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Intestatario bonifico', filled: true, fillColor: AppTheme.neroCard)),
          const SizedBox(height: 8),
          TextField(controller: _contoPostale, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Conto postale', filled: true, fillColor: AppTheme.neroCard)),
          const SizedBox(height: 8),
          TextField(controller: _intestatarioPostale, style: const TextStyle(color: AppTheme.bianco), decoration: const InputDecoration(hintText: 'Intestatario bollettino', filled: true, fillColor: AppTheme.neroCard)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _salvaPagamenti,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text('SALVA DATI PAGAMENTO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 24),
          const Text('Questa App e stata creata e realizzata da C.R.Software Milano\ninfo cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
        ],
      ),
    );
  }
}
