$ErrorActionPreference = "Stop"

Write-Host "Building Windows Release for Clod..."
flutter build windows --release

$isccPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)

$isccExe = $null
foreach ($path in $isccPaths) {
    if (Test-Path $path) {
        $isccExe = $path
        break
    }
}


Write-Host "Extracting version from pubspec.yaml..."
$pubspec = Get-Content pubspec.yaml -Raw
$versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*(?<version>[\d\.]+)')
$appVersion = "1.0.0"
if ($versionMatch.Success) {
    $appVersion = $versionMatch.Groups['version'].Value
}
Write-Host "App Version: $appVersion"

if ($isccExe) {
    Write-Host "Compiling Inno Setup Installer..."
    & $isccExe "/DMyAppVersion=$appVersion" "windows\packaging\inno_setup.iss"
    Write-Host "Windows Installer Complete! Outputs are in windows\packaging\Output\"
} else {
    Write-Host "Inno Setup not found. Built executable is in build\windows\x64\runner\Release\ but installer was not created."
    Write-Host "To create the installer, install Inno Setup 6 and run this script again."
}
