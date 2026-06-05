# ===============================================================================
#  STOCKAI — deploy-front.ps1
# ===============================================================================

param(
    [ValidateSet("mobile", "admin-web", "")]
    [string]$App = ""
)

$ErrorActionPreference = "Stop"

# -- Configuration --------------------------------------------------------------
$VPS_PORT    = "22"
$USER_HOST   = "sada@167.233.38.89"
$REMOTE_DIST = "/home/sada/projects/stockai/dist"

# Chemins locaux des deux projets
$FRONT_DIR = ".\stokai-front"

# -- Helpers --------------------------------------------------------------------
function Write-Step([string]$msg, [string]$color = "Cyan") {
    Write-Host "`n  > $msg" -ForegroundColor $color
}

Write-Host "`n---------------------------------------------------" -ForegroundColor Cyan
Write-Host "  STOCKAI - Deploy Frontend" -ForegroundColor Cyan
Write-Host "  Cible  : $USER_HOST" -ForegroundColor Cyan
Write-Host "---------------------------------------------------" -ForegroundColor Cyan

# ===============================================================================
#  FONCTION : Build + Deploy une app
# ===============================================================================
function Deploy-App {
    param(
        [string]$Name,          
        [string]$AppName,    
        [string]$BaseHref,
        [string]$DistPath,      
        [string]$RemoteFolder   
    )

    Write-Step "[$Name] Build en cours..."
    Push-Location $FRONT_DIR

    $BuildCmd = "npx nx build $AppName --configuration=production --base-href $BaseHref"
    Invoke-Expression $BuildCmd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Build de $Name echoue." -ForegroundColor Red
        Pop-Location; exit 1
    }

    if (-not (Test-Path $DistPath)) {
        Write-Host "[ERROR] Dossier dist introuvable : $DistPath" -ForegroundColor Red
        Pop-Location; exit 1
    }

    Write-Step "[$Name] Compression..."
    $ArchiveName = "$env:TEMP\stockai-$RemoteFolder-$((Get-Date).Ticks).tar.gz"
    tar -czf $ArchiveName -C $DistPath .

    Write-Step "[$Name] Transfert vers le serveur..."
    scp -P $VPS_PORT $ArchiveName "$($USER_HOST):/tmp/stockai-$RemoteFolder.tar.gz"

    Write-Step "[$Name] Extraction sur le serveur..."
    $remoteCmd = "rm -rf $REMOTE_DIST/$RemoteFolder && mkdir -p $REMOTE_DIST/$RemoteFolder && tar -xzf /tmp/stockai-$RemoteFolder.tar.gz -C $REMOTE_DIST/$RemoteFolder && rm /tmp/stockai-$RemoteFolder.tar.gz"
    ssh -p $VPS_PORT $USER_HOST $remoteCmd

    Remove-Item $ArchiveName -Force
    Pop-Location

    Write-Host "  [$Name] Deploye -> Dossier distant: $REMOTE_DIST/$RemoteFolder/" -ForegroundColor Green
}

# ===============================================================================
#  DÉPLOIEMENT DES APPS
# ===============================================================================

# -- PWA Mobile --
if ($App -eq "" -or $App -eq "mobile") {
    Deploy-App `
        -Name           "Mobile App" `
        -AppName        "mobile" `
        -BaseHref       "/mobile/" `
        -DistPath       "dist/apps/mobile/browser" `
        -RemoteFolder   "mobile"
}

# -- Admin Web --
if ($App -eq "" -or $App -eq "admin-web") {
    Deploy-App `
        -Name           "Admin Web" `
        -AppName        "admin-web" `
        -BaseHref       "/admin/" `
        -DistPath       "dist/apps/admin-web/browser" `
        -RemoteFolder   "admin-web"
}

Write-Host "`n---------------------------------------------------" -ForegroundColor Cyan
Write-Host "  DEPLOIEMENT FRONTEND TERMINE" -ForegroundColor Green
Write-Host "---------------------------------------------------`n" -ForegroundColor Cyan
