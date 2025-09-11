param([string]$outDir = '')

if ($outDir -ne '') {
    nuget pack libpjsua2maui.nuspec -OutputDirectory $outDir
}
else {
    nuget pack libpjsua2maui.nuspec
}