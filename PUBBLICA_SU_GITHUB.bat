@echo off
cd /d "%~dp0"
echo Installare strumenti necessari...
winget install -e --id Git.Git
winget install -e --id GitHub.cli
echo.
echo Login a GitHub (si apre il browser)...
gh auth login
echo.
echo Preparare deposito e pubblicare...
git init
git add .
git commit -m "Prima pubblicazione"
gh repo create spedizionefacile-demo --private --source=. --push
echo.
echo FATTO. Ora il progetto e' su GitHub.
