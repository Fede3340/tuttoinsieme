$ErrorActionPreference = "Stop"

# Percorsi progetto
$root    = Join-Path $env:USERPROFILE "Desktop\tuttoinsieme"
$laravel = Join-Path $root "laravel-spedizionefacile-main"
$nuxt    = Join-Path $root "nuxt-spedizionefacile-master"
$base    = "http://127.0.0.1:8787"

if (-not (Test-Path $laravel)) { throw "Cartella back-end non trovata: $laravel" }
if (-not (Test-Path $nuxt))    { throw "Cartella front-end non trovata: $nuxt" }
if (-not (Test-Path (Join-Path $root "Caddyfile"))) { throw "Caddyfile non trovato in: $root" }

function Stop-Port([int]$p) {
  $conns = Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue
  foreach ($c in $conns) {
    try { Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue } catch {}
  }
}

# Chiudere eventuali processi vecchi
Stop-Port 8787
Stop-Port 8000
Stop-Port 3000

# Avviare i tre pezzi in tre finestre separate
Start-Process powershell -WindowStyle Normal -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd `"$laravel`"; php artisan serve --host 127.0.0.1 --port 8000"
)

Start-Process powershell -WindowStyle Normal -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd `"$nuxt`"; npm run dev -- --host 127.0.0.1 --port 3000"
)

Start-Sleep -Seconds 2

Start-Process powershell -WindowStyle Normal -ArgumentList @(
  "-NoExit",
  "-Command",
  "cd `"$root`"; caddy run --config .\Caddyfile --adapter caddyfile"
)

function Wait-Http([string]$url, [int]$seconds = 40) {
  $sw = [Diagnostics.Stopwatch]::StartNew()
  while ($sw.Elapsed.TotalSeconds -lt $seconds) {
    try {
      $code = & curl.exe -s -o NUL -w "%{http_code}" $url
      if ([int]$code -ge 200 -and [int]$code -lt 500) { return $true }
    } catch {}
    Start-Sleep -Milliseconds 500
  }
  return $false
}

# Aspettare che risponda la pagina e l'endpoint di protezione
if (-not (Wait-Http "$base/" 40)) { throw "Non risponde $base/ (proxy/front-end non pronti)" }
if (-not (Wait-Http "$base/sanctum/csrf-cookie" 40)) { throw "Non risponde $base/sanctum/csrf-cookie (back-end non pronto)" }

# Jar biscotti (cookie) per la sessione
$jar = Join-Path $env:TEMP "sf_cookiejar.txt"
Remove-Item $jar -ErrorAction SilentlyContinue

function Get-Xsrf([string]$jarPath) {
  $line = (Get-Content $jarPath | Where-Object { $_ -match "XSRF-TOKEN" } | Select-Object -Last 1)
  if (-not $line) { throw "Manca XSRF-TOKEN nel jar: csrf-cookie non ha impostato il cookie." }
  $parts = $line -split "`t"
  $raw = $parts[-1]
  return [uri]::UnescapeDataString($raw)
}

# 1) Prendere i cookie di protezione
& curl.exe -s -c $jar "$base/sanctum/csrf-cookie" | Out-Null
$xsrf = Get-Xsrf $jar

# 2) Creare utente di test (casuale)
$rand = -join ((97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
$email = "test_$rand@example.com"
$pass  = "Test12345!"

$regPayload = @{
  name = "Test $rand"
  email = $email
  password = $pass
  password_confirmation = $pass
} | ConvertTo-Json

$regResp = & curl.exe -s -b $jar -c $jar `
  -H "Accept: application/json" `
  -H "Content-Type: application/json" `
  -H "X-XSRF-TOKEN: $xsrf" `
  -X POST -d $regPayload `
  "$base/api/custom-register"

# Se la registrazione richiede campi aggiuntivi, stampo la risposta e mi fermo
try { $regObj = $regResp | ConvertFrom-Json } catch { $regObj = $null }
if ($regObj -and $regObj.errors) {
  "REGISTRAZIONE FALLITA. Risposta completa:"
  $regResp
  throw "La registrazione richiede campi aggiuntivi non previsti nello script. Copia la risposta sopra."
}

# 3) Riprendere cookie protezione (sicurezza) e fare accesso
& curl.exe -s -b $jar -c $jar "$base/sanctum/csrf-cookie" | Out-Null
$xsrf = Get-Xsrf $jar

$loginPayload = @{ email = $email; password = $pass } | ConvertTo-Json

$loginResp = & curl.exe -s -b $jar -c $jar `
  -H "Accept: application/json" `
  -H "Content-Type: application/json" `
  -H "X-XSRF-TOKEN: $xsrf" `
  -X POST -d $loginPayload `
  "$base/api/custom-login"

# 4) Verificare /api/user: deve diventare 200
$userResp = & curl.exe -i -s -b $jar -H "Accept: application/json" "$base/api/user"

""
"=== CREDENZIALI DI TEST (create ora) ==="
"Email:    $email"
"Password: $pass"
""
"=== RISPOSTA /api/user (qui vuoi HTTP/1.1 200) ==="
$userResp
""

Start-Process "$base/"
"FINE"
