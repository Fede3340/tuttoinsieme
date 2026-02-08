@echo off
cd /d "%~dp0"
start "" "%~dp0AVVIA_TUTTO.bat"
echo.
echo Attendere che il sito sia avviato, poi parte il link pubblico...
timeout /t 3 >nul
cloudflared tunnel --url http://127.0.0.1:8787
