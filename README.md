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

### Se vedi errore 502 sulla porta 3000

- Aspetta 20-40 secondi e ricarica la pagina: Nuxt può impiegare qualche secondo al primo avvio.
- Se resta 502, dal Codespace usa **Command Palette → Codespaces: Rebuild Container** e riapri la porta **3000**.
- Il backend API deve rispondere sulla porta **8000**; se 8000 è su e 3000 no, il problema è solo nel processo Nuxt e il rebuild lo riallinea.

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
