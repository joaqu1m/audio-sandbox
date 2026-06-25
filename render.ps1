<#
.SYNOPSIS
  Gera partitura (PDF/PNG) + MIDI + MP3 a partir de um arquivo LilyPond (.ly).
.EXAMPLE
  .\render.ps1 musicas\03-fur-elise\fur_elise.ly
.EXAMPLE
  .\render.ps1 musicas\03-fur-elise\fur_elise.ly -SoundFont "C:\sf\orquestra.sf2"
#>
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$LyFile,
  [string]$SoundFont
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# localiza as ferramentas dentro de tools/ (independe da versão na subpasta)
$lily  = (Get-ChildItem -Recurse "$root\tools\lilypond"   -Filter lilypond.exe   -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
$fluid = (Get-ChildItem -Recurse "$root\tools\fluidsynth" -Filter fluidsynth.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $lily)  { throw "lilypond.exe nao encontrado em tools/lilypond  (veja 'Reobter as ferramentas' no README.md)" }
if (-not $fluid) { throw "fluidsynth.exe nao encontrado em tools/fluidsynth  (veja o README.md)" }
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) { throw "ffmpeg nao esta no PATH  -> winget install Gyan.FFmpeg" }

if (-not $SoundFont) { $SoundFont = "$root\Equinox_Grand_Pianos\Equinox_Grand_Pianos.sf2" }
if (-not (Test-Path $SoundFont)) { throw "soundfont nao encontrado: $SoundFont" }

$ly   = (Resolve-Path $LyFile).Path
$dir  = Split-Path $ly -Parent
$base = Join-Path $dir ([IO.Path]::GetFileNameWithoutExtension($ly))

Write-Host "1/3  LilyPond  ->  PDF / PNG / MIDI ..." -ForegroundColor Cyan
& $lily --pdf --png -dresolution=110 -o $base $ly
if ($LASTEXITCODE -ne 0) { throw "LilyPond falhou (veja os warnings acima)" }

$mid = "$base.mid"
if (Test-Path $mid) {
  $wav = "$base.wav"; $mp3 = "$base.mp3"
  Write-Host "2/3  FluidSynth -> WAV  (soundfont: $(Split-Path $SoundFont -Leaf)) ..." -ForegroundColor Cyan
  & $fluid -n -i -q -g 0.8 -C 0 -R 1 -r 44100 -T wav -F $wav $SoundFont $mid
  Write-Host "3/3  ffmpeg     -> MP3  (volume normalizado) ..." -ForegroundColor Cyan
  ffmpeg -y -loglevel error -i $wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" -codec:a libmp3lame -q:a 2 $mp3
  Remove-Item $wav -ErrorAction SilentlyContinue
}
else {
  Write-Host "(.ly sem bloco \midi{} -> nao gerei audio)" -ForegroundColor Yellow
}

Write-Host "`nPronto:" -ForegroundColor Green
Get-ChildItem "$base.*" | Where-Object { $_.Extension -in '.pdf', '.png', '.mid', '.mp3' } |
  Select-Object Name, @{N = 'KB'; E = { [math]::Round($_.Length / 1KB, 1) } } | Format-Table -AutoSize
