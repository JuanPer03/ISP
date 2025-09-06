# Script de Preparación del Sistema Operativo
Write-Host "==============================================" -ForegroundColor Green
Write-Host "INICIANDO PROCESO DE PREPARACIÓN DEL S.O." -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

# Inicializar variables para el resumen
$resumen = @()
$startTime = Get-Date

# Cambiar al directorio raíz
Write-Host "`n[1/7] Cambiando al directorio raíz..." -ForegroundColor Yellow
cd \
if ($PWD.Path -eq "C:\") {
    Write-Host "✓ Directorio actual: C:\" -ForegroundColor Green
    $resumen += "Directorio configurado: C:\"
} else {
    Write-Host "✗ Error al cambiar al directorio raíz" -ForegroundColor Red
    exit 1
}

# Descargar archivo ZIP
Write-Host "`n[2/7] Descargando archivo ZIP..." -ForegroundColor Yellow
$url = "https://fiunamedu-my.sharepoint.com/:u:/g/personal/juan_peralta_fi_unam_edu/Ec24uBPkqO5BqPVSBQbM_B4BJFmqWXLvpHC9XY_qu_ymsA?e=9z11eu"
$zipFile = "C:\TempProy1.zip"

try {
    # Usar WebClient para compatibilidad con versiones anteriores
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $zipFile)
    
    if (Test-Path $zipFile) {
        Write-Host "✓ Archivo descargado correctamente: $zipFile" -ForegroundColor Green
        $resumen += "Archivo descargado: $(Split-Path $zipFile -Leaf)"
    } else {
        throw "El archivo no se descargó correctamente"
    }
} catch {
    Write-Host "✗ Error al descargar el archivo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verificar si .NET 4.5 está disponible para compresión
Write-Host "`n[3/7] Verificando capacidades de compresión..." -ForegroundColor Yellow
try {
    # Intentar cargar el ensamblado de compresión
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
    Write-Host "✓ Módulo de compresión disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ .NET 4.5+ requerido para compresión: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Descomprimir archivo ZIP
Write-Host "`n[4/7] Descomprimiendo archivo..." -ForegroundColor Yellow
try {
    # Usar System.IO.Compression.ZipFile para compatibilidad
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, "C:\")
    
    if (Test-Path "C:\TempProy1") {
        Write-Host "✓ Archivo descomprimido en C:\TempProy1" -ForegroundColor Green
        $resumen += "Archivo descomprimido: C:\TempProy1"
    } else {
        throw "No se pudo descomprimir el archivo"
    }
} catch {
    Write-Host "✗ Error al descomprimir: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Cambiar al directorio TempProy1
Write-Host "`n[5/7] Cambiando al directorio de trabajo..." -ForegroundColor Yellow
cd "C:\TempProy1"
if ($PWD.Path -eq "C:\TempProy1") {
    Write-Host "✓ Directorio actual: C:\TempProy1" -ForegroundColor Green
} else {
    Write-Host "✗ Error al cambiar al directorio TempProy1" -ForegroundColor Red
    exit 1
}

# Instalar características de Windows
Write-Host "`n[6/7] Instalando características de Windows..." -ForegroundColor Yellow
$features = @(
    "RSAT-ADDS", "NET-Framework-45-Features", "RPC-over-HTTP-proxy", 
    "RSAT-Clustering", "WAS-Process-Model", "Web-Asp-Net45", 
    "Web-Basic-Auth", "Web-Client-Auth", "Web-Digest-Auth", 
    "Web-Dir-Browsing", "Web-Dyn-Compression", "Web-Http-Errors", 
    "Web-Http-Logging", "Web-Http-Redirect", "Web-Http-Tracing", 
    "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Lgcy-Mgmt-Console", 
    "Web-Metabase", "Web-Mgmt-Console", "Web-Mgmt-Service", 
    "Web-Net-Ext45", "Web-Request-Monitor", "Web-Server", 
    "Web-Stat-Compression", "Web-Static-Content", "Web-Windows-Auth", 
    "Web-WMI", "RSAT-Clustering-CmdInterface"
)

$installedFeatures = @()
$failedFeatures = @()

foreach ($feature in $features) {
    try {
        Write-Host "  Instalando: $feature" -ForegroundColor Gray
        
        # Usar Add-WindowsFeature para versiones anteriores o Install-WindowsFeature según disponibilidad
        if (Get-Command -Name Install-WindowsFeature -ErrorAction SilentlyContinue) {
            $result = Install-WindowsFeature $feature -ErrorAction Stop
        } elseif (Get-Command -Name Add-WindowsFeature -ErrorAction SilentlyContinue) {
            $result = Add-WindowsFeature $feature -ErrorAction Stop
        } else {
            throw "No se encontró comando para instalar características"
        }
        
        if ($result.Success -or $result.ExitCode -eq 0) {
            $installedFeatures += $feature
            Write-Host "  ✓ $feature instalado" -ForegroundColor Green
        } else {
            $failedFeatures += $feature
            Write-Host "  ✗ $feature falló" -ForegroundColor Red
        }
    } catch {
        $failedFeatures += $feature
        Write-Host "  ✗ Error con $feature : $($_.Exception.Message)" -ForegroundColor Red
    }
}

$resumen += "Características instaladas: $($installedFeatures.Count)/$($features.Count)"
if ($failedFeatures.Count -gt 0) {
    $resumen += "Características fallidas: $($failedFeatures.Count)"
}

# Instalar programas adicionales
Write-Host "`n[7/7] Instalando programas adicionales..." -ForegroundColor Yellow
$programs = @(
    @{Name="UCMA 4.0"; Path="C:\TempProy1\Programas\UcmaRuntimeSetup.exe"; Args="/quiet"},
    @{Name="VC++ 2013"; Path="C:\TempProy1\Programas\vcredist_x64.exe"; Args="/quiet /norestart"},
    @{Name="URL Rewrite"; Path="C:\TempProy1\Programas\rewrite_amd64.msi"; Args="/quiet /norestart"}
)

$installedPrograms = @()
$failedPrograms = @()

foreach ($program in $programs) {
    try {
        Write-Host "  Instalando: $($program.Name)" -ForegroundColor Gray
        if (Test-Path $program.Path) {
            # Usar Start-Process con verificación de tipo de archivo
            if ($program.Path.EndsWith(".msi")) {
                # Para MSI usar msiexec
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$($program.Path)`" $($program.Args)" -Wait -PassThru -NoNewWindow
            } else {
                # Para EXE usar directamente
                $process = Start-Process -FilePath $program.Path -ArgumentList $program.Args -Wait -PassThru -NoNewWindow
            }
            
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                $installedPrograms += $program.Name
                Write-Host "  ✓ $($program.Name) instalado" -ForegroundColor Green
            } else {
                throw "Código de salida: $($process.ExitCode)"
            }
        } else {
            throw "Archivo no encontrado: $($program.Path)"
        }
    } catch {
        $failedPrograms += $program.Name
        Write-Host "  ✗ Error instalando $($program.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

$resumen += "Programas instalados: $($installedPrograms.Count)/$($programs.Count)"
if ($failedPrograms.Count -gt 0) {
    $resumen += "Programas fallidos: $($failedPrograms.Count)"
}

# Mostrar resumen final
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "RESUMEN DE LA EJECUCIÓN" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Green
Write-Host "Tiempo total: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

foreach ($item in $resumen) {
    Write-Host "✓ $item" -ForegroundColor White
}

Write-Host "`nEstado final:" -ForegroundColor Yellow
if ($failedFeatures.Count -eq 0 -and $failedPrograms.Count -eq 0) {
    Write-Host "✅ TODAS LAS OPERACIONES SE COMPLETARON EXITOSAMENTE" -ForegroundColor Green
} else {
    Write-Host "⚠️  ALGUNAS OPERACIONES FALLARON" -ForegroundColor Yellow
    if ($failedFeatures.Count -gt 0) {
        Write-Host "Características fallidas: $($failedFeatures -join ', ')" -ForegroundColor Red
    }
    if ($failedPrograms.Count -gt 0) {
        Write-Host "Programas fallidos: $($failedPrograms -join ', ')" -ForegroundColor Red
    }
}

Write-Host "`nProceso completado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
