# TuttoInsieme Monorepo

Questo repository contiene:

- **Backend Laravel** in `laravel-spedizionefacile-main`
- **Frontend Nuxt** in `nuxt-spedizionefacile-master`

## Anteprime automatiche su Render (solo via interfaccia web)

> Tutti i passaggi qui sotto sono eseguibili dalla UI di Render, senza terminale.

1. **Crea un nuovo Blueprint**  
   - Vai su Render → *New* → *Blueprint* e collega questo repository.
   - Render rileverà automaticamente il file `render.yaml` in radice.

2. **Abilita le anteprime per le richieste di unione**  
   - Nella dashboard del servizio backend e frontend, assicurati che la voce *Preview Environments* sia attiva.
codex/locate-front-end-and-back-end-code-q3pzoc
   - La voce *Preview Environments* si abilita da UI: Render non accetta il campo `previewsEnabled` nel `render.yaml`.

main
   - Render creerà automaticamente un’anteprima per ogni Pull Request.

3. **Verifica le variabili d’ambiente**  
   - Il frontend usa la variabile `NUXT_PUBLIC_API_BASE` per raggiungere l’API Laravel.
   - Nel backend imposta le variabili minime (es. `APP_ENV`, `APP_KEY`, `APP_URL`, `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`).
   - Per ogni servizio, apri la sezione *Environment* in UI e controlla che i valori siano presenti.

4. **Database di anteprima**  
   - La Blueprint crea un database dedicato alle anteprime.
   - Controlla nella sezione *Databases* di Render che il database sia creato e collegato al backend.

5. **Apri l’anteprima**  
   - Apri una Pull Request e usa il link *Preview* generato da Render per visualizzare l’ultima versione.

## API Portafoglio (backend)

Il backend espone gli endpoint seguenti (base URL = `NUXT_PUBLIC_API_BASE`):

- `GET /api/wallet/balance` → saldo calcolato dai movimenti confermati.
- `GET /api/wallet/movements` → lista movimenti.
- `POST /api/wallet/top-up` → ricarica (idempotente).
- `POST /api/wallet/payment` → pagamento (idempotente, crea movimento in stato `pending`).
- `POST /api/wallet/payment-confirmation` → conferma pagamento tramite riferimento.

La logica è idempotente: lo stesso `idempotency_key` non crea movimenti duplicati e il saldo deriva sempre dai movimenti confermati.
