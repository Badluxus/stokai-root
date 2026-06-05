# ===============================================================================
#  STOCKAI — deploy-vps.ps1
# ===============================================================================

param(
    [switch]$Force    # Optionnel, gardé pour la compatibilité avec vos habitudes
)

# -- Configuration --------------------------------------------------------------
$VPS_IP        = "167.233.38.89"
$VPS_PORT      = "22"
$VPS_USER      = "sada"
$REMOTE_DIR    = "/home/sada/projects/stockai/backend"
$COMPOSE_FILE  = "docker-compose.yml"
$TMP_TAR       = "$env:TEMP\stockai-deploy-$((Get-Date).Ticks).tar"

# -- Helpers --------------------------------------------------------------------
function Write-Step([string]$msg, [string]$color = "Green") {
    Write-Host "`n  > $msg" -ForegroundColor $color
}

Write-Host "`n---------------------------------------------------" -ForegroundColor Cyan
Write-Host "  STOCKAI - Deploy VPS Backend" -ForegroundColor Cyan
Write-Host "  Cible  : $VPS_IP" -ForegroundColor Cyan
Write-Host "  Dossier: $REMOTE_DIR" -ForegroundColor Cyan
Write-Host "---------------------------------------------------" -ForegroundColor Cyan

# ===============================================================================
#  ÉTAPE 1 — Préparer le tar local (Code source)
#  Note: Contrairement à l'ancien projet, ici Docker build s'occupe de Maven
# ===============================================================================
Write-Step "[1/2] Préparation du package (Code Source)..."

if (Test-Path $TMP_TAR) { Remove-Item $TMP_TAR -Force }

$stagingDir = "$env:TEMP\stockai-staging"
if (Test-Path $stagingDir) { Remove-Item $stagingDir -Recurse -Force }
New-Item -ItemType Directory -Path $stagingDir | Out-Null

# Fichiers à transférer
Copy-Item "docker-compose.yml" "$stagingDir\docker-compose.yml"
Copy-Item "Caddyfile" "$stagingDir\Caddyfile"
if (Test-Path ".env") {
    Copy-Item ".env" "$stagingDir\.env"
    Write-Host "  .env inclus dans le package" -ForegroundColor Gray
} else {
    Write-Host "  [WARN] Pas de fichier .env trouvé localement !" -ForegroundColor Yellow
}

# Dossier backend
New-Item -ItemType Directory -Path "$stagingDir\stock-ai-backend" -Force | Out-Null
Copy-Item "stock-ai-backend\pom.xml" "$stagingDir\stock-ai-backend\pom.xml"
Copy-Item "stock-ai-backend\Dockerfile" "$stagingDir\stock-ai-backend\Dockerfile"
Copy-Item "stock-ai-backend\src" "$stagingDir\stock-ai-backend\src" -Recurse

tar -cf $TMP_TAR -C $stagingDir .
Remove-Item $stagingDir -Recurse -Force

$tarSize = [math]::Round((Get-Item $TMP_TAR).Length / 1MB, 1)
Write-Host "  Archive : $tarSize MB" -ForegroundColor Gray

# ===============================================================================
#  ÉTAPE 2 — Transfert + redémarrage
# ===============================================================================
Write-Step "[2/2] Transfert + redémarrage (Docker build distant)..."

# Créer le répertoire distant si nécessaire
ssh -p $VPS_PORT "$VPS_USER@$VPS_IP" "mkdir -p $REMOTE_DIR"

# -- Connexion 2 : transfert --
Write-Host "  Envoi du tar ($tarSize MB)..." -ForegroundColor Gray
scp -P $VPS_PORT -o "Compression=no" $TMP_TAR "$VPS_USER@$VPS_IP`:$REMOTE_DIR/deploy.tar"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Transfert SCP échoué." -ForegroundColor Red
    Remove-Item $TMP_TAR -Force; exit 1
}

# -- Connexion 3 : extraire + redémarrer --
Write-Host "  Extraction + redémarrage..." -ForegroundColor Gray

$remoteCmd = "cd $REMOTE_DIR && tar -xf deploy.tar && rm deploy.tar && docker compose -f $COMPOSE_FILE up -d --build"

ssh -p $VPS_PORT "$VPS_USER@$VPS_IP" $remoteCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Redémarrage échoué sur le serveur." -ForegroundColor Red
    Remove-Item $TMP_TAR -Force; exit 1
}

Remove-Item $TMP_TAR -Force

Write-Host "`n---------------------------------------------------" -ForegroundColor Cyan
Write-Host "  DEPLOIEMENT TERMINE" -ForegroundColor Green
Write-Host "---------------------------------------------------`n" -ForegroundColor Cyan
