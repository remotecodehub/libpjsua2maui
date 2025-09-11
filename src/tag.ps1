param(
    [Parameter(Mandatory = $true)]
    [string]$version,
    [switch]$delete,
    [switch]$push
)

function IsValidVersion($v) {
    return $v -match '^\d+\.\d+\.\d+(\.\d+)?$'
}

function TagExistsLocal($tagName) {
    return git tag | Where-Object { $_ -eq $tagName }
}

function TagExistsRemote($tagName) {
    return git ls-remote --tags origin | Select-String "refs/tags/$tagName"
}

function CreateSignedTag($v) {
    $tagName = "v$v"
    $tagMessage = "Release version $v"

    if (TagExistsLocal $tagName) {
        Write-Warning "⚠️ A tag local '$tagName' já existe. Use -delete para removê-la ou informe uma nova versão."
        return $false
    }

    try {
        git tag -s $tagName -m $tagMessage
        Write-Host "✅ Tag '$tagName' criada e assinada com sucesso."
        return $true
    } catch {
        Write-Warning "⚠️ Falha ao assinar a tag '$tagName'."
        $choice = Read-Host "Deseja tentar com outra versão (r) ou forçar criação sem assinatura (f)? [r/f]"
        if ($choice -match '^[rR]$') {
            $newVersion = Read-Host "Informe nova versão (formato X.X.X ou X.X.X.X)"
            if (IsValidVersion($newVersion)) {
                return CreateSignedTag $newVersion
            } else {
                Write-Error "❌ Versão inválida. Encerrando."
                exit 1
            }
        } elseif ($choice -match '^[fF]$') {
            git tag $tagName -m $tagMessage
            Write-Host "⚠️ Tag '$tagName' criada sem assinatura."
            return $true
        } else {
            Write-Error "❌ Opção inválida. Encerrando."
            exit 1
        }
    }
}

function PushTag($v) {
    $tagName = "v$v"

    if (TagExistsRemote $tagName) {
        Write-Warning "⚠️ A tag remota '$tagName' já existe."
        return $false
    }

    try {
        git push origin $tagName
        Write-Host "🚀 Tag '$tagName' enviada ao repositório remoto com sucesso."
        return $true
    } catch {
        Write-Error "❌ Falha ao enviar a tag '$tagName'."
        return $false
    }
}

function DeleteRemoteTag($v) {
    $tagName = "v$v"
    try {
        git push origin --delete $tagName
        Write-Host "🗑️ Tag remota '$tagName' removida com sucesso."
        return $true
    } catch {
        Write-Warning "⚠️ Falha ao remover a tag remota '$tagName'. Ela pode não existir."
        return $false
    }
}

function DeleteLocalTag($v) {
    $tagName = "v$v"
    try {
        git tag -d $tagName
        Write-Host "🗑️ Tag local '$tagName' removida com sucesso."
        return $true
    } catch {
        Write-Warning "⚠️ Falha ao remover a tag local '$tagName'. Ela pode não existir."
        return $false
    }
}

# Execução principal
if (-not (IsValidVersion $version)) {
    Write-Error "❌ Versão inválida. Use o formato X.X.X ou X.X.X.X"
    exit 1
}

$tagName = "v$version"

if ($push -and $delete) {
    Write-Host '🔁 Modo combinado: deletando e recriando a tag  $tagName ...'
    DeleteRemoteTag $version | Out-Null
    DeleteLocalTag $version | Out-Null

    if (CreateSignedTag $version) {
        PushTag $version | Out-Null
    }
    Exit 0;
}

if ($push) {
    if (CreateSignedTag $version) {
        PushTag $version | Out-Null
    }
    Exit 0;
}
if ($delete) {
    DeleteRemoteTag $version | Out-Null
    DeleteLocalTag $version | Out-Null
    Exit 0;
}

Write-Error '❌ Operação inválida. Use -push, -delete ou ambos para especificar a ação desejada.'
exit 1

