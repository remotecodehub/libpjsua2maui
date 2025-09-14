param ([Parameter(Mandatory=$true)][string]$version)

Write-Host " Validando .nuspec com nuget pack (modo dry-run)..." -ForegroundColor Blue

$output = & nuget pack libpjsua2maui.nuspec `
    -Version $version `
    -BasePath $PSScriptRoot `
    -NoPackageAnalysis `
    -NoDefaultExcludes `
    -Verbosity detailed 2>&1

if ($output -match "error") {
    Write-Host " Erro ao validar .nuspec. Detalhes:" -ForegroundColor Red
    Write-Output $output 
    exit 1
} else {
    Write-Debug " Validação bem-sucedida. Gerando pacote determinístico..."  
    & nuget pack libpjsua2maui.nuspec `
    -Version $version `
    -BasePath $PSScriptRoot `
    -NoPackageAnalysis `
    -NoDefaultExcludes
    Write-Host "Pacote disponivel em: libpjsua2maui.$version.nupkg" -ForegroundColor Green
}