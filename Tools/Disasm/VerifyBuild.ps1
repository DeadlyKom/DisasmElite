# Проверка уже собранного ELITE3HL.TRD без запуска ассемблера
# Сборку выполняет задача Build, здесь читаются только готовый образ и эталоны
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectDirectory = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$verificationPath = Join-Path $PSScriptRoot 'Reports/BuildVerification.json'

try {
    # Замена прежнего отчёта до проверки исключает выдачу старого успеха за новый
    [ordered]@{
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
        status = 'in_progress'
        method = 'existing_image'
        image = 'ELITE3HL.TRD'
        byte_identical = $null
    } | ConvertTo-Json | Set-Content -LiteralPath $verificationPath -Encoding utf8

    # Чтение готового образа, исходного диска и каталога извлечённых файлов
    $resultPath = Join-Path $projectDirectory 'ELITE3HL.TRD'
    $originalPath = Join-Path $PSScriptRoot 'Disk/original.trd'
    $manifestPath = Join-Path $PSScriptRoot 'Disk/manifest.json'
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $originalBytes = [System.IO.File]::ReadAllBytes($originalPath)
    $resultBytes = [System.IO.File]::ReadAllBytes($resultPath)

    # Проверка геометрии диска и числа исходных файлов перед сравнением
    if ($originalBytes.Length -ne 655360 -or $resultBytes.Length -ne 655360) {
        throw 'Ожидались исходный и собранный образы по 655360 байтов.'
    }
    if ($manifest.image_length -ne 655360 -or $manifest.files.Count -ne 7) {
        throw 'Каталог извлечения не соответствует семи файлам исходного образа.'
    }

    # Сравнение каждого байта готового TRD с неизменным исходным образом
    for ($byteIndex = 0; $byteIndex -lt $originalBytes.Length; $byteIndex++) {
        if ($originalBytes[$byteIndex] -ne $resultBytes[$byteIndex]) {
            throw "Первое различие TRD по смещению $byteIndex"
        }
    }
    $resultHash = (Get-FileHash -LiteralPath $resultPath -Algorithm SHA256).Hash

    # Проверка семи логических файлов непосредственно внутри готового образа
    $fileResults = @()
    foreach ($entry in $manifest.files) {
        $fileName = [string] $entry.filename
        $offset = [int] $entry.disk_offset
        $length = [int] $entry.length
        if ($offset -lt 4096 -or $length -lt 1 -or $offset + $length -gt $resultBytes.Length) {
            throw "Недопустимые границы логического файла $fileName"
        }
        $sourceRelative = "Tools/Disasm/Extracted/Active/$fileName"
        $sourceFile = Join-Path $projectDirectory $sourceRelative
        $sourceBytes = [System.IO.File]::ReadAllBytes($sourceFile)
        if ($sourceBytes.Length -ne $length) {
            throw "Длина извлечённого файла не совпадает с каталогом, $fileName"
        }
        $payload = New-Object byte[] $length
        [Array]::Copy($resultBytes, $offset, $payload, 0, $length)
        for ($byteIndex = 0; $byteIndex -lt $length; $byteIndex++) {
            if ($payload[$byteIndex] -ne $sourceBytes[$byteIndex]) {
                throw "Логический файл отличается от оригинала, $fileName"
            }
        }

        # Расчёт SHA-256 проверенного среза без создания промежуточного файла
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        try {
            $payloadHash = [BitConverter]::ToString($hasher.ComputeHash($payload)).Replace('-', '').ToLowerInvariant()
        } finally {
            $hasher.Dispose()
        }
        $fileResults += [ordered]@{
            file = $fileName
            bytes = $length
            disk_offset = $offset
            source = $sourceRelative
            sha256 = $payloadHash
            identical = $true
        }
    }

    # Сохранение результата проверки существующего образа без заявления о новой сборке
    [ordered]@{
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
        status = 'passed'
        method = 'existing_image'
        image = 'ELITE3HL.TRD'
        original = 'Tools/Disasm/Disk/original.trd'
        image_bytes = $resultBytes.Length
        byte_identical = $true
        sha256 = $resultHash.ToLowerInvariant()
        files = $fileResults
        semantic_audit = 'Tools/Disasm/Reports/SemanticAudit.json'
        note = 'Проверен готовый образ, ассемблер не запускался. Совпадение байтов не доказывает полноту смысловых комментариев.'
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $verificationPath -Encoding utf8
    Write-Host 'TRD проверен побайтово, ELITE3HL.TRD'
    Write-Host "SHA-256 $resultHash"
} catch {
    # Фиксация неуспешной проверки с путями относительно текущего проекта
    $reason = $_.Exception.Message.Replace($projectDirectory + '\', '').Replace($projectDirectory + '/', '')
    [ordered]@{
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
        status = 'failed'
        method = 'existing_image'
        image = 'ELITE3HL.TRD'
        byte_identical = $null
        error = $reason
    } | ConvertTo-Json | Set-Content -LiteralPath $verificationPath -Encoding utf8
    throw
}
