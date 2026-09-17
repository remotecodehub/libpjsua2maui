New-Item -ItemType Directory -Force -Path "artifacts" | Out-Null

$branch = (git branch --show-current).Trim()
$repo = (gh repo view --json owner, name --jq '"\(.owner.login)/\(.name)"').Trim()
$runId = (gh run list --branch $branch --limit 1 --json databaseId --jq '.[0].databaseId').Trim()

if (-not $runId) {
    Write-Error "Nenhum workflow encontrado para a branch atual ($branch)."
    exit 1
}

$artifactsJson = gh api "repos/$repo/actions/runs/$runId/artifacts" --jq '.artifacts[] | select(.name | test("^pjsip-2\\.17")) | .name'
$artifactNames = @($artifactsJson -split "`r?`n" | Where-Object { $_ -ne "" })

foreach ($name in $artifactNames) {
    $targetDir = "./artifacts/$name"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    gh run download $runId -n $name -D $targetDir
}