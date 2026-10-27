$ErrorActionPreference = 'Stop'
$taskAndroidDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\android'))
$taskKeyPath = Join-Path $taskAndroidDir 'upload-keystore.jks'
$taskPropertiesPath = Join-Path $taskAndroidDir 'key.properties'
if ((Test-Path -LiteralPath $taskKeyPath) -or (Test-Path -LiteralPath $taskPropertiesPath)) {
    throw 'Ya existe una clave o configuración de firma. No se sobrescribirá.'
}
$taskKeytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
if (-not (Test-Path -LiteralPath $taskKeytool)) { $taskKeytool = (Get-Command keytool -ErrorAction Stop).Source }
$env:TAREA7_KEY_PASSWORD = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
try {
    & $taskKeytool -genkeypair -keystore $taskKeyPath -alias upload -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS -storepass:env TAREA7_KEY_PASSWORD -keypass:env TAREA7_KEY_PASSWORD -dname 'CN=Caja de herramientas, OU=Proyecto academico, O=Desarrollo movil, C=DO' -noprompt
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar la clave.' }
    @("storePassword=$env:TAREA7_KEY_PASSWORD", "keyPassword=$env:TAREA7_KEY_PASSWORD", 'keyAlias=upload', 'storeFile=upload-keystore.jks') | Set-Content -LiteralPath $taskPropertiesPath -Encoding ascii
    Write-Output 'Clave de firma local creada. Conservar android/key.properties y android/upload-keystore.jks en una copia privada.'
} finally {
    Remove-Item Env:\TAREA7_KEY_PASSWORD -ErrorAction SilentlyContinue
}
