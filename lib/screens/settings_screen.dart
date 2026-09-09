import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/settings_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _temaChiaro = false;
  List<Map<String, String>> _roadmap = [];
  bool _loading = true;
  bool _checkUpdate = false;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final chiaro = await SettingsService.isTemaChiaro();
    final roadmap = await SettingsService.getRoadmap();
    if (!mounted) return;
    setState(() {
      _temaChiaro = chiaro;
      _roadmap = roadmap;
      _loading = false;
    });
  }

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

  Future<void> _cambiaLogo() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (img == null) return;
    final bytes = await File(img.path).readAsBytes();
    if (bytes.length > 900000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo troppo grande (max 900KB)'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    await SettingsService.salvaLogoBase64(base64Encode(bytes));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logo aggiornato su tutti i telefoni al prossimo avvio'), backgroundColor: AppTheme.verde),
    );
  }

  Future<void> _toggleTema(bool valore) async {
    await SettingsService.setTemaChiaro(valore);
    setState(() => _temaChiaro = valore);
  }

  @override
  Widget build(BuildContext context) {
    final chiaro = Theme.of(context).brightness == Brightness.light;
    final colTesto = chiaro ? AppTheme.testoScuro : AppTheme.bianco;
    final colSub = AppTheme.grigio;
    final accent = chiaro ? AppTheme.oroScuro : AppTheme.oro;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: accent), onPressed: () => Navigator.pop(context)),
        title: Text('IMPOSTAZIONI', style: AppTheme.titoloMedio.copyWith(color: accent)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.oro))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('ASPETTO', style: AppTheme.titoloMedio.copyWith(color: accent)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(_temaChiaro ? Icons.wb_sunny : Icons.dark_mode, color: accent),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Tema chiaro', style: TextStyle(color: colTesto, fontSize: 16))),
                      Switch(value: _temaChiaro, activeColor: accent, onChanged: _toggleTema),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('AGGIORNAMENTI APP', style: AppTheme.titoloMedio.copyWith(color: accent)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Controlla se c\'è una versione nuova sul server del club.', style: TextStyle(color: colTesto, fontSize: 14)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _checkUpdate ? null : _verificaUpdate,
                        icon: _checkUpdate ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.system_update_alt),
                        label: const Text('VERIFICA AGGIORNAMENTI'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.oro, foregroundColor: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('LOGO DEL CLUB', style: AppTheme.titoloMedio.copyWith(color: accent)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solo per il presidente', style: TextStyle(color: colSub, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('Sostituisci il logo: apparirà su tutti i telefoni al prossimo avvio.', style: TextStyle(color: colTesto, fontSize: 14)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _cambiaLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text('CARICA NUOVO LOGO'),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: accent), foregroundColor: accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('PROSSIMI AGGIORNAMENTI', style: AppTheme.titoloMedio.copyWith(color: accent)),
                const SizedBox(height: 10),
                ..._roadmap.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Icon(r['stato'] == 'in sviluppo' ? Icons.handyman : Icons.schedule, color: accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['titolo'] ?? '', style: TextStyle(color: colTesto, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(r['stato'] ?? '', style: TextStyle(color: accent, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                Text('INFO APP', style: AppTheme.titoloMedio.copyWith(color: accent)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La Nuova Milano Carpfishing A.S.D.', style: TextStyle(color: colTesto, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Sede 303 CFI', style: TextStyle(color: colSub)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('Questa App è stata creata e realizzata da C.R.Software Milano\ninfo cierre.software@gmail.com',
                    textAlign: TextAlign.center, style: TextStyle(color: colSub, fontSize: 11)),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
