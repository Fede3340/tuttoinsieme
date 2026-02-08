$ErrorActionPreference = "Stop"

$root = Join-Path $env:USERPROFILE "Desktop\tuttoinsieme"
if (!(Test-Path $root)) { throw "Non trovo la cartella: $root" }

function FindDirByFile($fileName) {
  Get-ChildItem -Path $root -Recurse -File -Filter $fileName -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\vendor\\" } |
    Select-Object -First 1 | ForEach-Object { $_.Directory.FullName }
}

$frontend = FindDirByFile "nuxt.config.ts"
$backend  = FindDirByFile "artisan"

if (-not $frontend) { throw "Non trovo nuxt.config.ts dentro $root" }
if (-not $backend)  { throw "Non trovo artisan dentro $root" }

Write-Host "Interfaccia:  $frontend"
Write-Host "Retro-fondo:  $backend"
Write-Host "Aprire SEMPRE: http://127.0.0.1:8787"

# Caddyfile (porta unica)
$caddyfilePath = Join-Path $root "Caddyfile"
$caddy = @"
:8787 {
  @api path /api/* /sanctum/*
  reverse_proxy @api 127.0.0.1:8000
  reverse_proxy 127.0.0.1:3000
}
"@
Set-Content -Path $caddyfilePath -Value $caddy -Encoding UTF8

# .env retro-fondo
$envPath = Join-Path $backend ".env"
$envExample = Join-Path $backend ".env.example"
if (!(Test-Path $envPath)) {
  if (Test-Path $envExample) { Copy-Item $envExample $envPath -Force }
  else { New-Item -Path $envPath -ItemType File | Out-Null }
}

function UpsertEnv($key, $value) {
  $t = Get-Content $envPath -Raw
  if ($t -match "(?m)^\s*$key=") {
    $t = [regex]::Replace($t, "(?m)^\s*$key=.*$", "$key=$value")
  } else {
    if (-not $t.EndsWith("`n")) { $t += "`n" }
    $t += "$key=$value`n"
  }
  Set-Content -Path $envPath -Value $t -NoNewline
}

UpsertEnv "APP_URL" "http://127.0.0.1:8787"
UpsertEnv "SESSION_DOMAIN" "127.0.0.1"
UpsertEnv "SESSION_SECURE_COOKIE" "false"
UpsertEnv "SESSION_DRIVER" "file"
UpsertEnv "SANCTUM_STATEFUL_DOMAINS" "127.0.0.1:8787,localhost:8787"

# Preparare retro-fondo
Push-Location $backend

if (!(Test-Path (Join-Path $backend "vendor\autoload.php"))) {
  Write-Host "Retro-fondo: installare dipendenze..."
  composer install
}

Write-Host "Retro-fondo: chiave e cache..."
php artisan key:generate --force | Out-Null
php artisan config:clear | Out-Null
php artisan cache:clear  | Out-Null
php artisan route:clear  | Out-Null

Write-Host "Retro-fondo: migrazioni..."
php artisan migrate --force | Out-Null

# Utente di prova (include telephone_number) + bypass blocchi campi
Write-Host "Retro-fondo: utente di prova..."
try {
  php artisan tinker --execute="use App\Models\User; User::unguard(); User::updateOrCreate(['email'=>'test@prova.it'], ['name'=>'Test','surname'=>'Test','telephone_number'=>'0000000000','password'=>bcrypt('Password123!')]);"
} catch {
  Write-Host "Avviso: utente di prova non creato. (Il sito può comunque avviarsi.)"
}

Pop-Location

# Preparare interfaccia
Push-Location $frontend
if (!(Test-Path (Join-Path $frontend "node_modules"))) {
  Write-Host "Interfaccia: installare dipendenze..."
  npm install
}
Pop-Location

# Avvio servizi (senza &&, con cartella di lavoro)
Write-Host "Avvio: retro-fondo 8000, interfaccia 3000, porta unica 8787..."
Start-Process -FilePath "cmd.exe" -WorkingDirectory $backend  -ArgumentList "/k", "php artisan serve --host 127.0.0.1 --port 8000"
Start-Process -FilePath "cmd.exe" -WorkingDirectory $frontend -ArgumentList "/k", "npm run dev -- --host 127.0.0.1 --port 3000"
Start-Process -FilePath "cmd.exe" -WorkingDirectory $root     -ArgumentList "/k", "caddy run --config .\Caddyfile --adapter caddyfile"

Start-Sleep -Seconds 2
Start-Process "http://127.0.0.1:8787"
