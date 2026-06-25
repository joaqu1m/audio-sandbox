<#
.SYNOPSIS
  Baixa os soundfonts (.sf2) usados pelo projeto, lendo soundfonts.json.
  Idempotente: pula os que ja existem e estao integros. Os que nao tem link
  direto (ex.: Equinox) viram instrucao de download manual.
.EXAMPLE
  .\soundfonts\fetch.ps1
.EXAMPLE
  .\soundfonts\fetch.ps1 -Force   # rebaixa mesmo os que ja existem
#>
param([switch]$Force)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$manifest = Join-Path $root 'soundfonts.json'
if (-not (Test-Path $manifest)) { throw "manifesto nao encontrado: $manifest" }
$items = Get-Content $manifest -Raw | ConvertFrom-Json

# valida que o arquivo e um SoundFont real (header RIFF....sfbk)
function Test-Sf2([string]$path) {
  if (-not (Test-Path $path)) { return $false }
  try {
    $fs = [System.IO.File]::OpenRead($path)
    try {
      $buf = New-Object byte[] 12
      if ($fs.Read($buf, 0, 12) -lt 12) { return $false }
    } finally { $fs.Close() }
    return ([System.Text.Encoding]::ASCII.GetString($buf, 0, 4) -eq 'RIFF') -and
           ([System.Text.Encoding]::ASCII.GetString($buf, 8, 4) -eq 'sfbk')
  } catch { return $false }
}

$ProgressPreference = 'SilentlyContinue'
$missing = @()
foreach ($it in $items) {
  $dest = Join-Path $root $it.file
  $tag  = if ($it.default) { "$($it.name) [default]" } else { $it.name }

  if ((Test-Sf2 $dest) -and -not $Force) {
    Write-Host "OK    $tag  (ja existe)" -ForegroundColor Green
    continue
  }
  if (-not $it.url) {
    Write-Host "MANUAL $tag  (sem link direto)" -ForegroundColor Yellow
    Write-Host "        pagina: $($it.page)" -ForegroundColor Yellow
    Write-Host "        $($it.notes)" -ForegroundColor DarkGray
    Write-Host "        salve como: $dest" -ForegroundColor DarkGray
    $missing += $it
    continue
  }

  Write-Host "GET   $tag" -ForegroundColor Cyan
  Write-Host "        <- $($it.url)" -ForegroundColor DarkGray
  $tmp = "$dest.part"
  try {
    Invoke-WebRequest -Uri $it.url -OutFile $tmp -MaximumRedirection 5
    if (-not (Test-Sf2 $tmp)) { throw "o arquivo baixado nao e um .sf2 valido (header RIFF/sfbk)" }
    Move-Item $tmp $dest -Force
    $mb = [math]::Round((Get-Item $dest).Length / 1MB, 1)
    Write-Host "        -> $($it.file)  ($mb MB)  OK" -ForegroundColor Green
  } catch {
    Remove-Item $tmp -ErrorAction SilentlyContinue
    Write-Host "        FALHOU: $_" -ForegroundColor Red
    $missing += $it
  }
}

Write-Host ""
if ($missing.Count -eq 0) {
  Write-Host "Todos os soundfonts prontos em: $root" -ForegroundColor Green
} else {
  Write-Host "Pendentes de download manual: $($missing.name -join ', ')" -ForegroundColor Yellow
}
