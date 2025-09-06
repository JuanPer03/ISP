# Cambiar al directorio raíz
cd \

# Descargar carpeta desde OneDrive
$url = "https://fiunamedu-my.sharepoint.com/:f:/g/personal/juan_peralta_fi_unam_edu/EvV08SgL45NHrQBoMik2WQoBNpuoscRq9cgd1fG7jBzbeQ?e=k3vfI2"
$destination = "C:\TempProy1"

Write-Host "Descargando carpeta desde OneDrive..." -ForegroundColor Yellow

try {
    # Crear directorio destino si no existe
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }
    
    # Método alternativo para descargar contenido de SharePoint/OneDrive
    # Usando web client para manejar la descarga
    $webClient = New-Object System.Net.WebClient
    
    # Lista de archivos esperados en la carpeta
    $filesToDownload = @(
        "Programas/UcmaRuntimeSetup.exe",
        "Programas/vcredist_x64.exe", 
        "Programas/rewrite_amd64.msi"
    )
    
    foreach ($file in $filesToDownload) {
        $filePath = Join-Path $destination $file
        $fileDir = Split-Path $filePath -Parent
        
        # Crear directorio si no existe
        if (-not (Test-Path $fileDir)) {
            New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
        }
        
        # Construir URL de descarga (aproximación - puede necesitar ajustes)
        $downloadUrl = $url -replace '\?e=.*$', "" + "/" + $file
        Write-Host "Descargando: $file" -ForegroundColor Cyan
        
        try {
            $webClient.DownloadFile($downloadUrl, $filePath)
            Write-Host "  ✓ $file descargado correctamente" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠ No se pudo descargar $file : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "Descarga de archivos completada" -ForegroundColor Green
}
catch {
    Write-Host "ERROR en la descarga: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Presiona Enter para salir..." -ForegroundColor Red
    Read-Host
    exit 1
}

# Verificar si los archivos esenciales se descargaron
$essentialFiles = @(
    "C:\TempProy1\Programas\UcmaRuntimeSetup.exe",
    "C:\TempProy1\Programas\vcredist_x64.exe",
    "C:\TempProy1\Programas\rewrite_amd64.msi"
)

$missingFiles = @()
foreach ($file in $essentialFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
        Write-Host "ADVERTENCIA: Archivo no encontrado - $file" -ForegroundColor Yellow
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Algunos archivos esenciales no se descargaron correctamente." -ForegroundColor Yellow
    Write-Host "Por favor, descarga manualmente la carpeta desde:" -ForegroundColor Yellow
    Write-Host $url -ForegroundColor Cyan
    Write-Host "Y colócala en C:\TempProy1" -ForegroundColor Yellow
    Write-Host "Presiona Enter para continuar con la instalación de características..." -ForegroundColor Yellow
    Read-Host
}

# Pausa después de descarga
Write-Host "Descarga completada. Presiona Enter para continuar con las instalaciones..." -ForegroundColor Cyan
Read-Host

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
        $result = Install-WindowsFeature -Name $feature -ErrorAction Stop
        if ($result.Success) {
            Write-Host "  ✓ $feature instalado correctamente" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $feature puede que no se instaló completamente" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ✗ Error instalando $feature : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Instalar programas adicionales (si se descargaron)
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
            $process = Start-Process -FilePath $program.Path -ArgumentList $program.Args -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Host "  ✓ $($program.Name) instalado correctamente" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ $($program.Name) terminó con código de salida: $($process.ExitCode)" -ForegroundColor Yellow
            }
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
