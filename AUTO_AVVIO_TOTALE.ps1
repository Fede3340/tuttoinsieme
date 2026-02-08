$ErrorActionPreference = "Stop"
$root = Join-Path $env:USERPROFILE "Desktop\tuttoinsieme"
$backend  = Join-Path $root "laravel-spedizionefacile-main"
$frontend = Join-Path $root "nuxt-spedizionefacile-master"
if (!(Test-Path $backend))  { throw "Non trovo retro-fondo: $backend" }
if (!(Test-Path $frontend)) { throw "Non trovo interfaccia: $frontend" }
Write-Host "Retro-fondo:  $backend"
Write-Host "Interfaccia:  $frontend"
Write-Host "Ingresso unico: http://127.0.0.1:8787"

$caddy = @(
":8787 {",
"  @api path /api/* /sanctum/*",
"  reverse_proxy @api 127.0.0.1:8000",
"  reverse_proxy 127.0.0.1:3000",
"}"
)
Set-Content -Path (Join-Path $root "Caddyfile") -Value $caddy -Encoding UTF8

Push-Location $backend
if (!(Test-Path (Join-Path $backend "vendor\autoload.php"))) { Write-Host "Composer: install..."; composer install }
php artisan key:generate --force | Out-Null
php artisan migrate --force | Out-Null
Pop-Location

Push-Location $frontend
if (!(Test-Path (Join-Path $frontend "node_modules"))) { Write-Host "NPM: install..."; npm install }
Pop-Location

Write-Host "Avvio servizi..."
Start-Process -FilePath "cmd.exe" -WorkingDirectory $backend  -ArgumentList "/k","php artisan serve --host 127.0.0.1 --port 8000"
Start-Process -FilePath "cmd.exe" -WorkingDirectory $frontend -ArgumentList "/k","npm run dev -- --host 127.0.0.1 --port 3000"
Start-Process -FilePath "cmd.exe" -WorkingDirectory $root     -ArgumentList "/k","caddy run --config .\Caddyfile --adapter caddyfile"
Start-Sleep -Seconds 2
Start-Process "http://127.0.0.1:8787"
Write-Host "Aprire SEMPRE il sito da: http://127.0.0.1:8787"
