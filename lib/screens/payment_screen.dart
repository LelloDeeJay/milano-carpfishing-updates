import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import 'waiting_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double importo;
  final String causale;
  final String? socioId;

  const PaymentScreen({super.key, required this.importo, required this.causale, this.socioId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  DatiPagamento? _dati;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final d = await ClubService.getDatiPagamento();
    setState(() => _dati = d);
  }

  void _copia(String testo, String nome) {
    Clipboard.setData(ClipboardData(text: testo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nome copiato'), backgroundColor: AppTheme.verde),
    );
  }

  Widget _cartellaPagamento({
    required String titolo,
    required String qrData,
    required List<String> righe,
    required String copiaTesto,
    required String copiaNome,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neroCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.oroScuro),
      ),
      child: Column(
        children: [
          Text(titolo, style: AppTheme.titoloMedio),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: QrImageView(data: qrData, size: 150, backgroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          ...righe.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(r, style: const TextStyle(color: AppTheme.bianco, fontSize: 13), textAlign: TextAlign.center),
              )),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _copia(copiaTesto, copiaNome),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.oro)),
            child: const Text('COPIA DATI', style: TextStyle(color: AppTheme.oro, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _dati;
    final pronti = d != null && d.iban.isNotEmpty;
    return Scaffold(
      backgroundColor: AppTheme.nero,
      appBar: AppBar(
        backgroundColor: AppTheme.nero,
        elevation: 0,
        title: const Text('PAGA LA QUOTA', style: AppTheme.titoloMedio),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text('EUR ${widget.importo.toStringAsFixed(2)}',
                  style: AppTheme.titoloGrande.copyWith(fontSize: 40)),
            ),
            const SizedBox(height: 4),
            Text(widget.causale, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.grigio, fontSize: 13)),
            const SizedBox(height: 24),
            if (!pronti)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.oroScuro.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Il presidente non ha ancora inserito i dati di pagamento. Riprova più tardi o contattalo.',
                  style: TextStyle(color: AppTheme.oroChiaro, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              _cartellaPagamento(
                titolo: 'BONIFICO BANCARIO',
                qrData: ClubService.qrBonificoSepa(d, widget.importo, widget.causale),
                righe: [
                  'IBAN: ${d.iban}',
                  'Intestatario: ${d.intestatario}',
                  'Inquadra col tuo home banking: il bonifico si compila da solo.',
                ],
                copiaTesto: d.iban,
                copiaNome: 'IBAN',
              ),
              const SizedBox(height: 16),
              if (d.contoPostale.isNotEmpty)
                _cartellaPagamento(
                  titolo: 'BOLLETTINO POSTALE',
                  qrData: ClubService.qrBollettino(d, widget.importo, widget.causale),
                  righe: [
                    'Conto: ${d.contoPostale}',
                    'Intestatario: ${d.intestatarioPostale}',
                  ],
                  copiaTesto: d.contoPostale,
                  copiaNome: 'Conto postale',
                ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WaitingScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.oro,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('HO PAGATO, ATTENDO CONFERMA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 20),
            const Text('Questa App è stata creata e realizzata da C.R.Software Milano — info cierre.software@gmail.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grigio, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
