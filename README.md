# TuttoInsieme Monorepo

Questo repository contiene:

- **Backend Laravel** in `laravel-spedizionefacile-main`
- **Frontend Nuxt** in `nuxt-spedizionefacile-master`

## Avvio con GitHub Codespaces (solo UI, senza terminale)

1. **Crea un Codespace**  
   - Vai su GitHub → *Code* → *Codespaces* → *Create codespace on main*.

2. **Attendi la configurazione automatica**  
   - Lo script `scripts/avvia-tutto.sh` installa le dipendenze mancanti e avvia Laravel (8000) e Nuxt (3000).

3. **Apri il sito**  
   - Apri il link della porta **3000** dalla scheda *Ports* del Codespace.

4. **Backend collegato automaticamente**  
   - `NUXT_PUBLIC_API_BASE` viene costruita usando `CODESPACE_NAME` e `GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`, così il frontend usa l’URL pubblico della porta 8000.

## API Portafoglio (backend)

Il backend espone gli endpoint seguenti (base URL = `NUXT_PUBLIC_API_BASE`):

- `GET /api/wallet/balance` → saldo calcolato dai movimenti confermati.
- `GET /api/wallet/movements` → lista movimenti.
- `POST /api/wallet/top-up` → ricarica (idempotente).
- `POST /api/wallet/payment` → pagamento (idempotente, crea movimento in stato `pending`).
- `POST /api/wallet/payment-confirmation` → conferma pagamento tramite riferimento.

La logica è idempotente: lo stesso `idempotency_key` non crea movimenti duplicati e il saldo deriva sempre dai movimenti confermati.
