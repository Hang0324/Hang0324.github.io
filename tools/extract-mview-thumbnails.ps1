param([string]$ProjectRoot)
$models = @('shiren','lvzhoujidi','kylie')
foreach ($name in $models) {
  $source = Join-Path $ProjectRoot ($name + '.mview')
  $target = Join-Path $ProjectRoot ('images/' + $name + '-cover.jpg')
  $bytes = [System.IO.File]::ReadAllBytes($source)
  $jpegStart = -1
  for ($i = 0; $i -lt [Math]::Min($bytes.Length - 1, 512); $i++) {
    if ($bytes[$i] -eq 0xFF -and $bytes[$i + 1] -eq 0xD8) { $jpegStart = $i; break }
  }
  if ($jpegStart -lt 0) { throw "No JPEG thumbnail found in $source" }
  $jpegEnd = -1
  for ($i = $jpegStart + 2; $i -lt $bytes.Length - 1; $i++) {
    if ($bytes[$i] -eq 0xFF -and $bytes[$i + 1] -eq 0xD9) { $jpegEnd = $i + 1; break }
  }
  if ($jpegEnd -lt 0) { throw "JPEG thumbnail is incomplete in $source" }
  $length = $jpegEnd - $jpegStart + 1
  $thumbnail = New-Object byte[] $length
  [Array]::Copy($bytes, $jpegStart, $thumbnail, 0, $length)
  [System.IO.File]::WriteAllBytes($target, $thumbnail)
  Write-Output "$name -> $target ($length bytes)"
}
