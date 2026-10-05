# Publish ASP.NET Core API for Somee.com File Manager / FTP upload
# Run from: Project 1\Project 1\
# Output: .\publish-somee\  and  .\publish-somee.zip

$ErrorActionPreference = "Stop"
$out = Join-Path $PSScriptRoot "publish-somee"
$zip = Join-Path $PSScriptRoot "publish-somee.zip"

if (Test-Path $out) {
    Remove-Item $out -Recurse -Force
}

Write-Host "Publishing Release build to $out ..."
dotnet publish "$PSScriptRoot\Project 1.csproj" -c Release -o $out
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed" }

$prod = Join-Path $PSScriptRoot "appsettings.Production.json"
$template = Join-Path $PSScriptRoot "somee-appsettings.Production.template.json"
if (Test-Path $prod) {
    Copy-Item $prod (Join-Path $out "appsettings.Production.json") -Force
    Write-Host "Copied appsettings.Production.json"
} elseif (Test-Path $template) {
    Copy-Item $template (Join-Path $out "appsettings.Production.json") -Force
    Write-Host "WARNING: copied template settings. Fill SQL and JWT before using the site."
} else {
    Write-Host "WARNING: No production settings found."
}

Copy-Item (Join-Path $PSScriptRoot "somee-web.config") (Join-Path $out "web.config") -Force
Write-Host "Wrote Somee web.config"

$logs = Join-Path $out "logs"
if (-not (Test-Path $logs)) {
    New-Item -ItemType Directory -Path $logs | Out-Null
}

if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $out "*") -DestinationPath $zip -Force

Write-Host ""
Write-Host "Done."
Write-Host "  Folder: $out"
Write-Host "  Zip:    $zip"
Write-Host ""
Write-Host "Somee File Manager -> Upload archive -> publish-somee.zip"
Write-Host "Then Restart the website. Test swagger on your Somee URL."
