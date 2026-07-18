/* ============================================================================
   VDS SERVICE v3 — Service Worker
   FIX rispetto alla v2 (cache-first su tutto = app mai aggiornata):
   - CACHE versionata: incrementa VERSION ad ogni release → vecchie cache eliminate
   - network-first per le navigazioni (HTML): gli utenti ricevono sempre
     l'ultima versione; la cache serve solo da fallback offline
   - cache-first solo per asset statici immutabili (icone, manifest)
   - skipWaiting + clients.claim: il nuovo SW prende il controllo subito
   - le chiamate a Supabase NON vengono mai messe in cache
   ============================================================================ */
'use strict';

const VERSION = 'v3.0.0';                    // ← incrementa ad ogni modifica dell'app
const CACHE = `vds-service-${VERSION}`;
const STATIC_ASSETS = ['index.html', 'manifest.json', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(STATIC_ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);

  // Mai intercettare API esterne (Supabase, CDN): rete diretta
  if (url.origin !== location.origin) return;

  // HTML → network-first con fallback cache (offline)
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put('index.html', copy));
          return res;
        })
        .catch(() => caches.match('index.html'))
    );
    return;
  }

  // Asset statici → cache-first
  e.respondWith(
    caches.match(e.request).then((hit) => hit || fetch(e.request).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(e.request, copy));
      return res;
    }))
  );
});
