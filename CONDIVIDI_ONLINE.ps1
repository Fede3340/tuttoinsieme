$ErrorActionPreference = "Stop"

$root = Join-Path $env:USERPROFILE "Desktop\tuttoinsieme"
$avvioBat = Join-Path $root "AVVIA_TUTTO.bat"
if (!(Test-Path $avvioBat)) { throw "Non trovo: $avvioBat" }

# 1) Avvia sito (retro-fondo + interfaccia + porta unica)
Start-Process $avvioBat

# 2) Avvia collegamento pubblico e salva log
$log = Join-Path $root "LINK_PUBBLICO.log"
Remove-Item $log -Force -ErrorAction SilentlyContinue

$proc = Start-Process -FilePath "cloudflared" -ArgumentList "tunnel","--url","http://127.0.0.1:8787" `
  -RedirectStandardOutput $log -RedirectStandardError $log -PassThru -WindowStyle Hidden

# 3) Aspetta che compaia il link trycloudflare, poi:
#    - lo copia negli appunti
#    - lo apre nel browser
while ($true) {
  if (Test-Path $log) {
    $t = Get-Content $log -Raw
    if ($t -match 'https://[^\s]+trycloudflare\.com') {
      $url = $matches[0]
      Set-Clipboard $url
      Start-Process $url
      Write-Host ""
      Write-Host "LINK PUBBLICO (copiato negli appunti): $url"
      Write-Host "Lascia questa finestra aperta per mantenerlo online."
      break
    }
  }
  Start-Sleep -Seconds 1
}

# Non chiudere: se chiudi, puoi spegnere il collegamento
Wait-Process -Id $proc.Id
