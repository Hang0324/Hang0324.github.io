param(
  [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$mviewRoot = Join-Path $ProjectRoot 'Mview'

if (-not (Test-Path -LiteralPath $mviewRoot -PathType Container)) {
  throw "Mview folder was not found: $mviewRoot"
}

$workFolders = Get-ChildItem -LiteralPath $mviewRoot -Directory |
  Where-Object { $_.Name -match '^Work\d+$' } |
  Sort-Object Name

$updated = 0
foreach ($folder in $workFolders) {
  $source = Join-Path $folder.FullName 'model.mview'
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    Write-Warning "$($folder.Name): model.mview not found, skipped."
    continue
  }

  $bytes = [System.IO.File]::ReadAllBytes($source)
  $jpegStart = -1
  $scanLimit = [Math]::Min($bytes.Length - 1, 1048576)
  for ($i = 0; $i -lt $scanLimit; $i++) {
    if ($bytes[$i] -eq 0xFF -and $bytes[$i + 1] -eq 0xD8) {
      $jpegStart = $i
      break
    }
  }
  if ($jpegStart -lt 0) {
    Write-Warning "$($folder.Name): embedded JPEG thumbnail not found, skipped."
    continue
  }

  $jpegEnd = -1
  for ($i = $jpegStart + 2; $i -lt $bytes.Length - 1; $i++) {
    if ($bytes[$i] -eq 0xFF -and $bytes[$i + 1] -eq 0xD9) {
      $jpegEnd = $i + 1
      break
    }
  }
  if ($jpegEnd -lt 0) {
    Write-Warning "$($folder.Name): embedded JPEG thumbnail is incomplete, skipped."
    continue
  }

  $length = $jpegEnd - $jpegStart + 1
  if ($length -lt 1024) {
    Write-Warning "$($folder.Name): embedded thumbnail is unexpectedly small, skipped."
    continue
  }

  $thumbnail = New-Object byte[] $length
  [Array]::Copy($bytes, $jpegStart, $thumbnail, 0, $length)

  $target = Join-Path $folder.FullName 'cover.jpg'
  $backup = Join-Path $folder.FullName 'cover.backup.jpg'
  $temporary = Join-Path $folder.FullName 'cover.new.jpg'
  [System.IO.File]::WriteAllBytes($temporary, $thumbnail)
  if (Test-Path -LiteralPath $target -PathType Leaf) {
    Copy-Item -LiteralPath $target -Destination $backup -Force
  }
  Move-Item -LiteralPath $temporary -Destination $target -Force
  $updated++
  Write-Host "$($folder.Name): cover.jpg updated ($([Math]::Round($length / 1KB)) KB)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Updated $updated cover image(s)." -ForegroundColor Cyan

