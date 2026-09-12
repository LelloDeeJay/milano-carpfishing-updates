import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/bacheca_service.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import '../services/settings_service.dart';
import 'settings_screen.dart';
import '../services/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  Socio? _socio;
  List<Evento> _eventi = [];
  List<Avviso> _avvisi = [];
  List<Documento> _documenti = [];
  DateTime _giorno = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('socioId') ?? '';
    final soci = await ClubService.getSoci();
    Socio? trovato;
    for (final s in soci) {
      if (s.id == id) trovato = s;
    }
    final eventi = await ClubService.getEventi();
    final avvisi = await BachecaService.getAvvisi();
    final documenti = await BachecaService.getDocumenti();
    setState(() {
      _socio = trovato;
      _eventi = eventi;
      _avvisi = avvisi;
      _documenti = documenti;
    });
  }


  bool _checkUpdate = false;

  Future<void> _verificaUpdate() async {
    setState(() => _checkUpdate = true);
    final upd = await UpdateService.checkUpdate();
    if (!mounted) return;
    setState(() => _checkUpdate = false);
    if (upd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sei già aggiornato all\'ultima versione'), backgroundColor: AppTheme.verde),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.neroCard,
        title: const Text('AGGIORNAMENTO DISPONIBILE', style: AppTheme.titoloMedio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuova versione: ${upd.versione}', style: const TextStyle(color: AppTheme.bianco)),
            const SizedBox(height: 8),
            Text(upd.note.isEmpty ? 'Scarica e installa il nuovo APK.' : upd.note,
                style: const TextStyle(color: AppTheme.grigio, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('PIÙ TARDI', style: TextStyle(color: AppTheme.grigio))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.apriDownload(upd.urlDownload);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black),
            child: const Text('AGGIORNA ORA'),
          ),
        ],
      ),
    );
  }

  Future<void> _esci() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggato', false);
    await prefs.setBool('attivo', false);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  DateTime? _parseData(String s) {
    final p = s.split('/');
    if (p.length != 3) return null;
    final g = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final a = int.tryParse(p[2]);
    if (g == null || m == null || a == null) return null;
    return DateTime(a, m, g);
  }

  List<Evento> _eventiDelGiorno(DateTime d) {
    return _eventi.where((e) {
      final dt = _parseData(e.data);
      return dt != null && dt.year == d.year && dt.month == d.month && dt.day == d.day;
    }).toList();
  }

  Future<void> _aderisci(Evento e) async {
    final s = _socio;
    if (s == null) return;
    await ClubService.aderisciEvento(e.id, s.id);
    await _carica();
  }

  Widget _paginaHome() {
    final s = _socio;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Benvenuto, ${s != null ? s.nome : 'socio'}!', style: AppTheme.titoloMedio),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.neroCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.oroScuro)),
          child: Column(
            children: [
              const Text('LA NUOVA MILANO CARPFISHING A.S.D.', style: AppTheme.sottotitolo, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const Text('Sede 303 CFI', style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
              const SizedBox(height: 12),
              Container(
                color: AppTheme.verde,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: const Text('PASSIONE • RISPETTO • AMICIZIA • NATURA', style: AppTheme.valori),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('BACHECA DEL CLUB', style: AppTheme.titoloMedio),
        const SizedBox(height: 8),
        if (_avvisi.isEmpty)
          const Text('Nessun avviso in bacheca.', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
        ..._avvisi.map((a) => Card(
              color: AppTheme.neroCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.oroScuro)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: AppTheme.oro, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(a.titolo, style: const TextStyle(color: AppTheme.oroChiaro, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(a.testo, style: const TextStyle(color: AppTheme.bianco, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(a.data, style: const TextStyle(color: AppTheme.grigio, fontSize: 11)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 24),
        const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
      ],
    );
  }

  Widget _paginaGare() {
    final s = _socio;
    final delGiorno = _eventiDelGiorno(_giorno);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('PROSSIME GARE', style: AppTheme.titoloMedio),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(initialCenter: LatLng(42.8, 12.2), initialZoom: 5.4),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'it.crsoftware.milano_carpfishing_303_asd',
                ),
                MarkerLayer(
                  markers: [
                    for (final e in _eventi)
                      Marker(
                        point: LatLng(e.lat, e.lng),
                        width: 34,
                        height: 34,
                        child: const Icon(Icons.location_on, color: AppTheme.verde, size: 34),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TableCalendar(
          firstDay: DateTime(2026, 1, 1),
          lastDay: DateTime(2027, 12, 31),
          focusedDay: _giorno,
          selectedDayPredicate: (d) => isSameDay(d, _giorno),
          onDaySelected: (sel, foc) => setState(() => _giorno = sel),
          eventLoader: _eventiDelGiorno,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(color: AppTheme.oroChiaro, fontSize: 16, fontWeight: FontWeight.bold),
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.oro),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.oro),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: AppTheme.bianco),
            weekendTextStyle: const TextStyle(color: AppTheme.bianco),
            outsideTextStyle: const TextStyle(color: AppTheme.grigio),
            selectedDecoration: const BoxDecoration(color: AppTheme.oro, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: AppTheme.verde.withValues(alpha: 0.6), shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: AppTheme.verde, shape: BoxShape.circle),
            markersMaxCount: 3,
          ),
        ),
        const SizedBox(height: 16),
        if (delGiorno.isEmpty)
          const Text('Nessun evento nel giorno selezionato.', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
        ...delGiorno.map((e) {
          final haAderito = s != null && e.partecipanti.contains(s.id);
          return Card(
            color: AppTheme.neroCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.oroScuro)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.data, style: const TextStyle(color: AppTheme.oroChiaro, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(e.nome, style: const TextStyle(color: AppTheme.bianco, fontSize: 16)),
                  Text(e.luogo, style: const TextStyle(color: AppTheme.bianco, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('${e.partecipanti.length} partecipanti', style: const TextStyle(color: AppTheme.grigio, fontSize: 13)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: haAderito ? null : () => _aderisci(e),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black),
                    child: Text(haAderito ? 'HAI ADERITO' : 'ISCRIVITI'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _paginaChat() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: AppTheme.oro, size: 60),
          SizedBox(height: 12),
          Text('CHAT DEL CLUB', style: AppTheme.titoloMedio),
          SizedBox(height: 8),
          Text('In arrivo col prossimo aggiornamento', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _paginaSegreteria() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SEGRETERIA DEL CLUB', style: AppTheme.titoloMedio),
        const SizedBox(height: 8),
        const Text('Moduli e documenti ufficiali della Sede 303 CFI.', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
        const SizedBox(height: 16),
        if (_documenti.isEmpty)
          const Text('Nessun documento caricato.', style: TextStyle(color: AppTheme.grigio, fontSize: 13)),
        ..._documenti.map((d) => Card(
              color: AppTheme.neroCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.oroScuro)),
              child: ListTile(
                leading: const Icon(Icons.description, color: AppTheme.oro),
                title: Text(d.nome, style: const TextStyle(color: AppTheme.bianco)),
                subtitle: Text('${d.descrizione}\n${d.data}', style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
              ),
            )),
        const SizedBox(height: 24),
        const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
      ],
    );
  }

  Widget _paginaTesserino() {
    final s = _socio;
    if (s == null) return const Center(child: Text('Tesserino non trovato', style: TextStyle(color: AppTheme.grigio)));
    final qrData = 'CFI303|${s.numeroTessera}|${s.nome} ${s.cognome}|${s.codiceFiscale}';
    final etichettaRuolo = s.ruolo == 'presidente'
        ? 'PRESIDENTE'
        : s.ruolo == 'vice'
            ? 'VICE PRESIDENTE'
            : s.ruolo == 'segretario'
                ? 'SEGRETARIO'
                : 'SOCIO ATTIVO';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.neroCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.oro, width: 3),
          ),
          child: Column(
            children: [
              const Text('LA NUOVA MILANO CARPFISHING A.S.D.', style: AppTheme.sottotitolo, textAlign: TextAlign.center),
              const Text('Sede 303 CFI', style: TextStyle(color: AppTheme.grigio, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 90,
                    height: 110,
                    decoration: BoxDecoration(color: AppTheme.grigio.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.person, size: 50, color: AppTheme.nero),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.nome} ${s.cognome}', style: AppTheme.titoloMedio),
                        const SizedBox(height: 4),
                        Text('N° ${s.numeroTessera}', style: const TextStyle(color: AppTheme.bianco, fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.verde, borderRadius: BorderRadius.circular(12)),
                          child: Text(etichettaRuolo, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6),
                child: QrImageView(data: qrData, size: 120, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('VALIDO FINO AL ${s.scadenzaQuota}', style: const TextStyle(color: AppTheme.oroChiaro, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
      ],
    );
  }

  Widget _paginaProfilo() {
    final s = _socio;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('IL MIO PROFILO', style: AppTheme.titoloMedio),
        const SizedBox(height: 16),
        if (s != null) ...[
          _rigaProfilo('Nome e cognome', '${s.nome} ${s.cognome}'),
          _rigaProfilo('Email', s.email),
          _rigaProfilo('Data di nascita', s.dataNascita),
          _rigaProfilo('Luogo di nascita', s.luogoNascita),
          _rigaProfilo('Indirizzo', s.indirizzo),
          _rigaProfilo('Città e CAP', '${s.citta} (${s.cap})'),
          _rigaProfilo('Codice fiscale', s.codiceFiscale),
          _rigaProfilo('Tessera', 'N° ${s.numeroTessera}'),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            final prima = await SettingsService.isTemaChiaro();
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            final dopo = await SettingsService.isTemaChiaro();
            if (prima != dopo && mounted) {
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: const Text('IMPOSTAZIONI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _checkUpdate ? null : _verificaUpdate,
          icon: _checkUpdate ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.system_update_alt),
          label: const Text('VERIFICA AGGIORNAMENTI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => UpdateService.apriReleases(),
          icon: const Icon(Icons.history),
          label: const Text('VEDI STORICO AGGIORNAMENTI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro), foregroundColor: AppTheme.oro, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _esci,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
          child: const Text('ESCI', style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(height: 20),
        const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
      ],
    );
  }

  Widget _rigaProfilo(String etichetta, String valore) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 130, child: Text(etichetta, style: const TextStyle(color: AppTheme.grigio, fontSize: 13))),
            Expanded(child: Text(valore, style: const TextStyle(color: AppTheme.bianco, fontSize: 14))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pagine = [
      _paginaHome(),
      _paginaGare(),
      _paginaChat(),
      _paginaTesserino(),
      _paginaSegreteria(),
      _paginaProfilo(),
    ];
    return Scaffold(
      backgroundColor: AppTheme.nero,
      body: pagine[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: AppTheme.neroCard,
        selectedItemColor: AppTheme.oro,
        unselectedItemColor: AppTheme.grigio,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Gare'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Tesserino'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Segreteria'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
    );
  }
}
