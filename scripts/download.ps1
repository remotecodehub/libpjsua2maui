[CmdletBinding()]
param()

# Configura a cultura da sessão/thread atual para en-US
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
[System.Threading.Thread]::CurrentThread.CurrentUICulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')

# Garante o encerramento do script em caso de erros fatais
$ErrorActionPreference = 'Stop'

function Write-ColorHost {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorHost "==> Starting artifact download process..." Green

# 1. Resolve o caminho absoluto da pasta raiz do repositório
# $PSScriptRoot corresponde ao diretório 'libpjsua2maui/scripts'
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# Subindo um nível para chegar na raiz do repositório ('libpjsua2maui')
$repoRoot = Resolve-Path (Join-Path -Path $scriptDir -ChildPath "..")

Write-ColorHost "Repository root resolved to: $repoRoot" Cyan

# Altera temporariamente o diretório para executar os comandos do Git e GH CLI
Set-Location -Path $repoRoot

try {
    # 2. Obtém a branch atual via Git
    Write-ColorHost "Detecting current Git branch..." Yellow
    $currentBranch = (git branch --show-current).Trim()

    if (-not $currentBranch) {
        throw "Could not determine the current Git branch. Ensure you are inside a Git repository."
    }

    Write-ColorHost "Current branch: $currentBranch" Cyan

    # 3. Define e cria o diretório de destino 'libpjsua2maui/artifacts'
    $artifactsDir = Join-Path -Path $repoRoot -ChildPath "artifacts"
    if (-not (Test-Path -Path $artifactsDir)) {
        Write-ColorHost "Creating target artifacts directory at '$artifactsDir'..." Yellow
        New-Item -Path $artifactsDir -ItemType Directory | Out-Null
    } else {
        Write-ColorHost "Target artifacts directory exists at '$artifactsDir'." Gray
    }

    # 4. Obtém o ID da última execução (run) do workflow para a branch atual
    Write-ColorHost "Fetching the latest workflow run ID for branch '$currentBranch'..." Yellow
    $runId = (gh run list --branch $currentBranch --limit 1 --json databaseId --jq '.[0].databaseId').Trim()

    if (-not $runId) {
        throw "No workflow runs found for branch '$currentBranch'."
    }

    Write-ColorHost "Latest workflow run ID found: $runId" Cyan

    # 5. Baixa todos os artefatos da run para a pasta artifacts
    Write-ColorHost "Downloading all artifacts from run $runId to '$artifactsDir'..." Yellow
    gh run download $runId --dir $artifactsDir

    Write-ColorHost "==> Success! All artifacts have been downloaded to '$artifactsDir'." Green

} catch {
    Write-ColorHost "ERROR: $($_.Exception.Message)" Red
    exit 1
}