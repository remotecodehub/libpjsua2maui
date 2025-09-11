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
        $choice = Read-Host "Deseja remover a tag remota (r) ou criar nova versão local (n)? [r/n]"
        if ($choice -match '^[rR]$') {
            DeleteRemoteTag $v
            DeleteLocalTag $v
            $newVersion = Read-Host "Informe nova versão (formato X.X.X ou X.X.X.X)"
            if (IsValidVersion($newVersion)) {
                if (CreateSignedTag $newVersion) {
                    PushTag $newVersion
                }
            } else {
                Write-Error "❌ Versão inválida. Encerrando."
                exit 1
            }
        } elseif ($choice -match '^[nN]$') {
            $newVersion = Read-Host "Informe nova versão (formato X.X.X ou X.X.X.X)"
            if (IsValidVersion($newVersion)) {
                if (CreateSignedTag $newVersion) {
                    PushTag $newVersion
                }
            } else {
                Write-Error "❌ Versão inválida. Encerrando."
                exit 1
            }
        } else {
            Write-Error "❌ Opção inválida. Encerrando."
            exit 1
        }
    } else {
        try {
            git push origin $tagName
            Write-Host "🚀 Tag '$tagName' enviada ao repositório remoto com sucesso."
        } catch {
            Write-Error "❌ Falha ao enviar a tag '$tagName'."
            exit 1
        }
    }
}

function DeleteRemoteTag($v) {
    $tagName = "v$v"
    try {
        git push origin --delete $tagName
        Write-Host "🗑️ Tag remota '$tagName' removida com sucesso."
        return $true
    } catch {
        Write-Error "❌ Falha ao remover a tag remota '$tagName'."
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
        Write-Error "❌ Falha ao remover a tag local '$tagName'."
        return $false
    }
}

# Execução principal
if (-not (IsValidVersion $version)) {
    Write-Error "❌ Versão inválida. Use o formato X.X.X ou X.X.X.X"
    exit 1
}

if ($push) {
    if (CreateSignedTag $version) {
        PushTag $version
    }
} elseif ($delete) {
    if (DeleteRemoteTag $version) {
        DeleteLocalTag $version
    }
} else {
    Write-Error "❌ Operação inválida. Use -push para criar/enviar ou -delete para especificar a operação"
    Exit 1
}