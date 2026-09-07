$ErrorActionPreference = "Stop"

Write-Host "Building Android Release APK and AAB for Clod..."
Write-Host "Checking for keystore..."

$keystorePath = "android/app/upload-keystore.jks"
if (-not (Test-Path $keystorePath)) {
    Write-Host "Keystore not found. Generating a new release keystore..."
    keytool -genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias upload -dname "CN=Clod, OU=Mobile, O=Clod, L=City, S=State, C=US" -storepass "clod123" -keypass "clod123"
}

Write-Host "Creating key.properties..."
$properties = @"
storePassword=clod123
keyPassword=clod123
keyAlias=upload
storeFile=upload-keystore.jks
"@
$properties | Out-File -Encoding utf8 android/key.properties

Write-Host "Building APK..."
flutter build apk --release

Write-Host "Building AAB..."
flutter build appbundle --release

Write-Host "Android Build Complete! Outputs are in build/app/outputs/flutter-apk/ and build/app/outputs/bundle/release/"
