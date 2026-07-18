# VDS Service

App web/PWA per richieste di assistenza e manutenzione furgoni Mercedes.

**Come funziona:** il cliente invia la richiesta (problema, km, foto, posizione GPS) e riceve un codice di tracciamento; il titolare la vede nella dashboard protetta in tempo reale e conferma il giorno di manutenzione.

## Struttura

| File | Descrizione |
|---|---|
| `index.html` | App completa (vista Cliente + Dashboard Titolare) |
| `sw.js` | Service worker — cache versionata, network-first per l'HTML |
| `manifest.json` | Manifest PWA (installabile su Android/iOS) |
| `setup-supabase.sql` | Setup database, RLS, storage foto, realtime |
| `LEGGIMI.md` | Guida completa: demo locale, Supabase, deploy, PWA |
| `icon-*.png` | Icone app |

## Avvio rapido

```bash
python3 -m http.server 8080   # poi apri http://localhost:8080
```

Modalità demo (dati locali, PIN dashboard: 1234). Per il database condiviso vedi [LEGGIMI.md](LEGGIMI.md).

## Stack

HTML/CSS/JS vanilla · Supabase (DB, Auth, Storage, Realtime) · PWA (Service Worker, Web Manifest) · Geolocation API
