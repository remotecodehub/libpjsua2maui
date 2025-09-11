param([Parameter(Mandatory = $true)][string]$version)

function IsValidVersion($v) {
    return $v -match '^\d+\.\d+\.\d+(\.\d+)?$'
}

function CreateSignedTag($v) {
    $tagName = "v$v"
    $tagMessage = "Release version $v"
    try {
        git tag -s $tagName -m $tagMessage
        Write-Host "✅ Tag '$tagName' criada e assinada com sucesso."
        return $true
    } catch {
        Write-Warning "⚠️ Falha ao assinar a tag '$tagName'."
        $choice = Read-Host "Deseja tentar novamente com outra versão (r) ou forçar a criação sem assinatura (f)? [r/f]"
        if ($choice -eq 'r') {
            $newVersion = Read-Host "Informe nova versão (formato X.X.X ou X.X.X.X)"
            if (IsValidVersion($newVersion)) {
                return CreateSignedTag $newVersion
            } else {
                Write-Error "❌ Versão inválida. Encerrando."
                exit 1
            }
        } elseif ($choice -eq 'f') {
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
    try {
        git push origin $tagName
        Write-Host "🚀 Tag '$tagName' enviada ao repositório remoto com sucesso."
    } catch {
        Write-Warning "⚠️ Falha ao enviar a tag '$tagName'. Ela pode já existir no remoto."
        $choice = Read-Host "Deseja remover a tag remota (r) ou criar uma nova versão local (n)? [r/n]"
        if ($choice -eq 'r') {
            git push origin --delete $tagName
            Write-Host "🗑️ Tag remota '$tagName' removida."
            git push origin $tagName
            Write-Host "🚀 Tag '$tagName' reenviada ao remoto."
        } elseif ($choice -eq 'n') {
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
    }
}

# Execução principal
if (-not (IsValidVersion $version)) {
    Write-Error "❌ Versão inválida. Use o formato X.X.X ou X.X.X.X"
    exit 1
}

if (CreateSignedTag $version) {
    PushTag $version
}