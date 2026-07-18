-- ============================================================================
-- VDS SERVICE v3 — Setup database Supabase
-- Esegui questo script in: Supabase → SQL Editor → New query → Run
-- ============================================================================

-- 1) Tabella richieste ------------------------------------------------------
create table if not exists public.richieste (
  id                uuid primary key,
  codice            text not null unique,
  created_at        timestamptz not null default now(),
  nome              text not null,
  telefono          text not null,
  modello           text not null,
  targa             text,
  km                integer not null check (km between 0 and 2000000),
  problema          text not null,
  data_preferita    date not null,
  luogo             text not null,
  lat               double precision,
  lng               double precision,
  foto              jsonb not null default '[]'::jsonb,
  stato             text not null default 'in_attesa'
                    check (stato in ('in_attesa','programmata','completata')),
  data_appuntamento date
);

-- 2) Row Level Security -----------------------------------------------------
-- I clienti (anonimi) possono SOLO inserire. Solo il titolare autenticato
-- può leggere e aggiornare. Nessuno può cancellare via API.
alter table public.richieste enable row level security;

create policy "clienti inseriscono"
  on public.richieste for insert
  to anon
  with check (stato = 'in_attesa' and data_appuntamento is null);

create policy "titolare legge"
  on public.richieste for select
  to authenticated
  using (true);

create policy "titolare aggiorna"
  on public.richieste for update
  to authenticated
  using (true);

-- 3) Funzione per il cliente: verifica stato tramite codice ------------------
-- SECURITY DEFINER: espone SOLO stato e data appuntamento, niente dati personali.
create or replace function public.stato_richiesta(p_codice text)
returns table (stato text, data_appuntamento date)
language sql
security definer
set search_path = public
stable
as $$
  select r.stato, r.data_appuntamento
  from public.richieste r
  where r.codice = upper(p_codice)
  limit 1;
$$;

grant execute on function public.stato_richiesta(text) to anon;

-- 4) Storage per le foto ----------------------------------------------------
-- Bucket pubblico in lettura; gli anonimi possono solo caricare.
insert into storage.buckets (id, name, public)
values ('foto', 'foto', true)
on conflict (id) do nothing;

create policy "upload foto clienti"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'foto');

create policy "lettura foto"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'foto');

-- 5) Realtime ---------------------------------------------------------------
-- Abilita gli aggiornamenti live della dashboard.
alter publication supabase_realtime add table public.richieste;
