cd ~/milano_carpfishing_303_asd && cat > README.md << 'EOFREADME'
# 🎣 La Nuova Milano Carpfishing A.S.D. - Sede 303 CFI

**App ufficiale per la gestione del club di pesca sportiva**

![Versione](https://img.shields.io/badge/versione-1.0.3-blue)
![Piattaforma](https://img.shields.io/badge/piattaforma-Android-green)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange)

---

## 📱 Cos'è

App mobile per la gestione digitale del club **La Nuova Milano Carpfishing A.S.D.**, sede 303 CFI (Carpa Fishing Italia). Sostituisce completamente la gestione cartacea di tesserini, quote, eventi e comunicazioni.

---

## ✨ Funzionalità Principali

### 👤 Per i Soci
- **Tesserino digitale** con QR code personale
- **Attivazione tessera** tramite codice fornito dal presidente
- **Profilo personale** con dati anagrafici completi
- **Scelta tema chiaro/scuro** personalizzabile
- **Aggiornamenti automatici** dell'app senza Play Store

### 👑 Per il Presidente (PIN 3030)
- **Pannello di controllo completo**
  - Crea nuovi soci manualmente
  - Attiva/disattiva tessere
  - Segna quote pagate
  - Gestisci quote mensili (gennaio-dicembre)
  - Configura dati di pagamento (IBAN, conto postale)
  - Rimuovi soci dal club
- **Gestione eventi**
  - Crea gare con mappa e coordinate GPS
  - Visualizza partecipanti
  - Calendario mensile interattivo
- **Bacheca del club**
  - Pubblica avvisi per tutti i soci
  - Carica documenti ufficiali (statuto, regolamento)
- **Aggiorna logo del club** (appare su tutti i telefoni)

### 🗺️ Mappa Gare
- Visualizzazione OpenStreetMap delle location gare
- Coordinate GPS precise
- Pin interattivi con dettagli evento

### 📅 Calendario Eventi
- Calendario mensile con evidenza giorni gara
- Dettaglio evento con luogo, data, partecipanti
- Sistema di adesione alle gare

### 💳 Pagamenti
- QR code per bonifico SEPA (precompilato con IBAN e causale)
- QR code per bollettino postale
- Nessuna transazione in-app: sicurezza massima

### ☁️ Sincronizzazione Cloud
- **Firebase Firestore** per dati condivisi
- Presidente inserisce socio → appare su tutti i telefoni
- Avvisi bacheca visibili in tempo reale
- Logo del club sincronizzato

---

## 🚀 Installazione

### Per i Soci
1. Scarica l'APK da questo repository (sezione Releases)
2. Abilita "Installa da origini sconosciute" nelle impostazioni Android
3. Installa l'APK
4. Apri l'app e scegli:
   - **ATTIVA TESSERINO** (se hai già il codice dal presidente)
   - **ISCRIVITI** (se sei un nuovo socio)

### Per il Presidente
1. Installa l'app come sopra
2. Dalla schermata di login, clicca **AREA PRESIDENTE** (link in basso)
3. Inserisci il PIN: **3030**

---

## 🔄 Sistema Aggiornamenti

L'app verifica automaticamente la presenza di nuove versioni su questo repository GitHub.

### Per il Presidente (pubblicare aggiornamento)
```bash
./publish.sh