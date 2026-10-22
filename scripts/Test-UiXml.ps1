param([string]$Language = 'vietnam')

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$flashRoot = Split-Path $PSScriptRoot -Parent
$archive = [System.IO.Compression.ZipFile]::OpenRead((Join-Path $flashRoot "ui/$Language/xml.png"))
$failures = @()
try {
    foreach ($entry in $archive.Entries) {
        $stream = $entry.Open()
        try {
            $xml = New-Object System.Xml.XmlDocument
            $xml.Load($stream)
        } catch {
            $failures += "xml.png/$($entry.FullName): $($_.Exception.Message)"
        } finally {
            $stream.Dispose()
        }
    }
    Write-Output "Validated $($archive.Entries.Count) packed UI XML files."
} finally {
    $archive.Dispose()
}
foreach ($file in Get-ChildItem (Join-Path $flashRoot "ui/$Language/xml") -Filter '*.xml' -File) {
    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.Load($file.FullName)
    } catch {
        $failures += "$($file.Name): $($_.Exception.Message)"
    }
}
if ($failures.Count) {
    $failures | Write-Output
    throw "$($failures.Count) invalid UI XML files."
}
Write-Output 'PASS: packed and loose UI XML files are well formed.'
