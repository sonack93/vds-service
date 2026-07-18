# VDS Service v3 — Guida rapida

App per richieste di assistenza furgoni Mercedes: i clienti inviano la richiesta (problema, km, foto, posizione GPS), tu la vedi nella dashboard e confermi il giorno di manutenzione.

## Cosa c'è di nuovo nella v3

| Problema della v2 | Soluzione v3 |
|---|---|
| Le richieste restavano sul telefono del cliente | Database condiviso **Supabase** (gratuito): arrivano davvero a te |
| Dashboard aperta a chiunque | **Login** titolare (email+password); in demo un PIN |
| Foto base64 → spazio esaurito dopo poche richieste | Foto caricate su **Supabase Storage**, errore quota gestito |
| App installata mai aggiornata (cache-first) | Service worker **network-first** con cache versionata |
| GPS negato = campo vuoto | **Fallback**: indirizzo scrivibile a mano, errori spiegati |
| Nessuna conferma per il cliente | **Codice richiesta** (VDS-XXXXXX) + verifica stato in app |
| Date passate selezionabili, km liberi | Validazioni complete su tutti i campi |

## 1. Prova subito (modalità demo)

Apri `index.html` con un piccolo server locale (necessario per foto e service worker):

```bash
cd vds-service-v3
python3 -m http.server 8080
# poi apri http://localhost:8080
```

In demo i dati restano sul dispositivo (vedrai il banner giallo). PIN dashboard: **1234**.

## 2. Attiva il database condiviso (Supabase, ~10 minuti)

1. Crea un account gratuito su [supabase.com](https://supabase.com) → **New project**.
2. Nel progetto: **SQL Editor → New query**, incolla tutto il contenuto di `setup-supabase.sql` e premi **Run**.
3. Crea il tuo utente titolare: **Authentication → Users → Add user** (email + password; disattiva "Send email invite" se non serve).
4. Copia le chiavi: **Settings → API** → `Project URL` e `anon public key`.
5. Apri `index.html` e incollale nel blocco `CONFIG` in alto nello script:

```js
const CONFIG = {
  SUPABASE_URL: 'https://TUOPROGETTO.supabase.co',
  SUPABASE_ANON_KEY: 'eyJ…',
  DEMO_PIN: '1234'   // usato solo se le chiavi sono vuote
};
```

Fatto: le richieste dei clienti ora arrivano alla tua dashboard in tempo reale, da qualsiasi dispositivo.

> La `anon key` è pensata per stare nel codice pubblico: la sicurezza è garantita dalle policy RLS (i clienti possono solo inserire, solo tu leggi e aggiorni).

## 3. Pubblica online (HTTPS obbligatorio per GPS e PWA)

Opzione più semplice — **Netlify**:
1. Vai su [app.netlify.com/drop](https://app.netlify.com/drop)
2. Trascina la cartella `vds-service-v3`
3. Ottieni un indirizzo `https://…netlify.app` da condividere con i clienti

## 4. Installa come app (PWA)

- **Android (Chrome):** apri il sito → menu ⋮ → "Aggiungi a schermata Home"
- **iPhone (Safari):** condividi → "Aggiungi a Home"

## 5. App native (facoltativo)

- [PWABuilder](https://www.pwabuilder.com): inserisci l'URL del sito → genera pacchetti Android (Play Store) e iOS
- In alternativa **Capacitor** per un progetto nativo completo

## Aggiornare l'app

Dopo ogni modifica ai file, incrementa `VERSION` in `sw.js` (es. `v3.0.1`) e ricarica su Netlify: gli utenti riceveranno la nuova versione alla prossima apertura.

## Prossimi passi consigliati

- **Notifiche push** quando arriva una richiesta (Supabase Edge Functions + Web Push)
- **SMS/WhatsApp di conferma** al cliente quando accetti la data
- Backup periodico: Supabase → Database → Backups (automatici nel piano gratuito)
