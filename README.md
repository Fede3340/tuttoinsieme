# TuttoInsieme Monorepo

Questo repository contiene:

- **Backend Laravel** in `laravel-spedizionefacile-main`
- **Frontend Nuxt** in `nuxt-spedizionefacile-master`

## Avvio con GitHub Codespaces (solo UI, senza terminale)

1. **Crea un Codespace**  
   - Vai su GitHub → *Code* → *Codespaces* → *Create codespace on main*.

2. **Attendi la configurazione automatica**  
   - Il setup installa le dipendenze di Laravel e Nuxt e avvia entrambi i server.

3. **Apri il sito**  
   - Quando le porte sono pronte, GitHub mostrerà un link per la porta **3000** (Nuxt).

4. **Backend collegato**  
   - Il frontend legge l’API da `NUXT_PUBLIC_API_BASE`, già configurata nel Codespace per puntare alla porta **8000**.
   - Se serve, puoi cambiare `NUXT_PUBLIC_API_BASE` dal pannello *Environment* del Codespace (UI).

## API Portafoglio (backend)

Il backend espone gli endpoint seguenti (base URL = `NUXT_PUBLIC_API_BASE`):

- `GET /api/wallet/balance` → saldo calcolato dai movimenti confermati.
- `GET /api/wallet/movements` → lista movimenti.
- `POST /api/wallet/top-up` → ricarica (idempotente).
- `POST /api/wallet/payment` → pagamento (idempotente, crea movimento in stato `pending`).
- `POST /api/wallet/payment-confirmation` → conferma pagamento tramite riferimento.

La logica è idempotente: lo stesso `idempotency_key` non crea movimenti duplicati e il saldo deriva sempre dai movimenti confermati.
