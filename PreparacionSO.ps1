# Cambiar al directorio raíz
cd \

# Descargar el archivo zip
$url = "https://fiunamedu-my.sharepoint.com/:u:/g/personal/juan_peralta_fi_unam_edu/Ec24uBPkqO5BqPVSBQbM_B4BJFmqWXLvpHC9XY_qu_ymsA?e=9z11eu"
$zipFile = "C:\TempProy1.zip"
Write-Host "Descargando archivo zip..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Verificar si el archivo se descargó correctamente
if (Test-Path $zipFile) {
    Write-Host "Descarga completada exitosamente" -ForegroundColor Green
} else {
    Write-Host "Error en la descarga" -ForegroundColor Red
    exit 1
}

# Verificar si .NET Framework 4.5 o superior está instalado para la descompresión
$net45Installed = Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 378389 }
$net48Installed = Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 528040 }

if (-not ($net45Installed -or $net48Installed)) {
    Write-Host "Se requiere .NET Framework 4.5 o superior para descomprimir" -ForegroundColor Red
    exit 1
}

# Descomprimir el archivo zip
Write-Host "Descomprimiendo archivo..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, "C:\")
    Write-Host "Descompresión completada exitosamente" -ForegroundColor Green
}
catch {
    Write-Host "Error al descomprimir: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Cambiar al directorio TempProy1
cd TempProy1

# Instalar características de Windows
Write-Host "Instalando características de Windows..." -ForegroundColor Yellow

$features = @(
    "RSAT-ADDS",
    "NET-Framework-45-Features",
    "RPC-over-HTTP-proxy",
    "RSAT-Clustering",
    "WAS-Process-Model",
    "Web-Asp-Net45",
    "Web-Basic-Auth",
    "Web-Client-Auth",
    "Web-Digest-Auth",
    "Web-Dir-Browsing",
    "Web-Dyn-Compression",
    "Web-Http-Errors",
    "Web-Http-Logging",
    "Web-Http-Redirect",
    "Web-Http-Tracing",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Lgcy-Mgmt-Console",
    "Web-Metabase",
    "Web-Mgmt-Console",
    "Web-Mgmt-Service",
    "Web-Net-Ext45",
    "Web-Request-Monitor",
    "Web-Server",
    "Web-Stat-Compression",
    "Web-Static-Content",
    "Web-Windows-Auth",
    "Web-WMI",
    "RSAT-Clustering-CmdInterface"
)

foreach ($feature in $features) {
    try {
        Write-Host "Instalando: $feature" -ForegroundColor Cyan
        Install-WindowsFeature -Name $feature -ErrorAction Stop
        Write-Host "  ✓ $feature instalado correctamente" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Error instalando $feature : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Instalar programas adicionales
Write-Host "Instalando programas adicionales..." -ForegroundColor Yellow

$programs = @(
    @{Name = "UCMA 4.0"; Path = "C:\TempProy1\Programas\UcmaRuntimeSetup.exe"; Args = "/quiet"},
    @{Name = "VC++ 2013"; Path = "C:\TempProy1\Programas\vcredist_x64.exe"; Args = "/quiet /norestart"},
    @{Name = "URL Rewrite Module"; Path = "C:\TempProy1\Programas\rewrite_amd64.msi"; Args = "/quiet /norestart"}
)

foreach ($program in $programs) {
    if (Test-Path $program.Path) {
        try {
            Write-Host "Instalando: $($program.Name)" -ForegroundColor Cyan
            Start-Process -FilePath $program.Path -ArgumentList $program.Args -Wait -NoNewWindow
            Write-Host "  ✓ $($program.Name) instalado correctamente" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ Error instalando $($program.Name) : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✗ Archivo no encontrado: $($program.Path)" -ForegroundColor Red
    }
}

Write-Host "Proceso completado!" -ForegroundColor Green
Write-Host "Reinicia el sistema para completar la instalación de algunas características." -ForegroundColor Yellow

# Solicitar presionar Enter para finalizar
Write-Host ""
Write-Host "Presiona Enter para finalizar..." -ForegroundColor White -BackgroundColor DarkBlue
Read-Host
