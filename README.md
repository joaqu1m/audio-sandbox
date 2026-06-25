# 🎵 audio-sandbox

Estúdio de **música como código** — open-source, gratuito e editável. Fluxo oficial:

```
.ly (LilyPond)  ──►  partitura (PDF / PNG)
                └──►  MIDI  ──►  áudio .mp3   (FluidSynth + soundfont)
```

Uma única fonte de texto (`.ly`) gera **partitura E áudio**. Versionável, editável nota a nota, sem nunca perder qualidade.

---

## Por que LilyPond (e não MIDI puro)?

- **Uma fonte da verdade**: o mesmo arquivo `.ly` vira partitura *e* MIDI.
- **Texto puro**: versionável no Git (dá pra dar *diff* na música), modular, scriptável.
- **O que melhora o áudio melhora a partitura**: dinâmica (`\p \f`), pedal e articulação são as mesmas marcações nos dois lados.
- O caminho inverso (código → MIDI → partitura) gera **notação suja**. Quer ver por quê? Olhe `musicas/03-fur-elise/jornada/` — é a saga toda documentada.

---

## Pré-requisitos

Tudo já vem em `tools/` (portátil, sem instalação):

| Ferramenta | O que faz | Onde |
|---|---|---|
| **LilyPond 2.26** | `.ly` → PDF/PNG + MIDI | `tools/lilypond/` |
| **FluidSynth 2.5.5** | MIDI → áudio via soundfont | `tools/fluidsynth/` |
| **ffmpeg** | WAV → MP3 normalizado | precisa estar no **PATH** |
| **Soundfont (.sf2)** | o timbre (piano) | `Equinox_Grand_Pianos/` |

> `ffmpeg` é a única dependência externa: `winget install Gyan.FFmpeg`
> (Para reobter LilyPond/FluidSynth, veja o fim deste arquivo.)

---

## Gerar uma música nova — do início ao fim

1. **Crie a pasta** da música:
   ```powershell
   mkdir musicas\04-minha-musica
   ```
2. **Copie o template** e renomeie:
   ```powershell
   copy musicas\_template.ly musicas\04-minha-musica\minha-musica.ly
   ```
3. **Componha** editando o `.ly` (sintaxe abaixo).
4. **Renderize tudo** com um comando:
   ```powershell
   .\render.ps1 musicas\04-minha-musica\minha-musica.ly
   ```
5. Saem no mesmo diretório: **`.pdf`, `.png`, `.mid` e `.mp3`**. 🎉

> **Erro de _execution policy_** ao rodar o script numa máquina nova? Habilite scripts locais uma vez (config. padrão recomendada pela Microsoft, **não** é bypass):
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

Trocar o instrumento/soundfont (ex.: orquestral):
```powershell
.\render.ps1 musicas\04-minha-musica\minha-musica.ly -SoundFont "C:\caminho\orquestra.sf2"
```

---

## Sintaxe LilyPond — referência rápida

```lilypond
% NOTA = letra + oitava. c' = dó central (C4); cada ' sobe oitava, cada , desce.
c' d' e'              % dó ré mi          | c'' = C5   | a, = A2 (grave)
% ACIDENTES: is = sustenido, es = bemol  | cis' = C#4   ees' = Eb4
% DURAÇÃO = número após a nota (vale até você trocar):
c'16  c'8  c'4  c'2  c'1     % semicolcheia, colcheia, semínima, mínima, semibreve
c'4.                         % ponto = +50%
% ACORDE: notas entre < >
<c' e' g'>2                  % dó maior (mínima)
% DINÂMICA:  \p \mp \mf \f   | crescendo \< ... \!   | decrescendo \> ... \!
c'4\p d'\< e' f'\f
% PEDAL:
g'2\sustainOn  a'2\sustainOff
% ESTRUTURA:  { } = sequencial    << >> = simultâneo
% \key a \minor   \time 3/4   \tempo 4 = 120   \repeat unfold 2 { ... }
```

Exemplo completo e comentado: **`musicas/03-fur-elise/fur_elise.ly`**.

### Vários instrumentos (rumo ao orquestral)

Cada `\new Staff` é uma voz/instrumento; defina o timbre MIDI com `midiInstrument`:
```lilypond
\new Staff { \set Staff.midiInstrument = "violin" \violinos }
\new Staff { \set Staff.midiInstrument = "cello"  \cellos }
```
Para soar como orquestra de verdade, troque o soundfont de piano por um orquestral via `-SoundFont`.

---

## Estrutura do repositório

```
audio-sandbox/
├── README.md                  ← este arquivo
├── render.ps1                 ← .ly → pdf + png + mid + mp3 (um comando)
├── Equinox_Grand_Pianos/      ← soundfont de piano (.sf2)
├── tools/                     ← LilyPond + FluidSynth (portáteis, ~130 MB)
└── musicas/
    ├── _template.ly           ← ponto de partida pra peças novas
    ├── 01-trilha/             ← experimento inicial em Python/mido *
    ├── 02-ambient/            ← experimento inicial em Python/mido *
    └── 03-fur-elise/          ← exemplo OFICIAL em LilyPond
        ├── fur_elise.ly
        └── jornada/           ← a saga até o LilyPond (por que MIDI→partitura não presta)
```
\* `01` e `02` nasceram em Python (`mido`) antes de adotarmos o LilyPond — ficam como referência histórica. **O fluxo oficial é o LilyPond.**

---

## Reobter ferramentas e soundfont (não versionados no Git)

> `tools/` e o soundfont **não** vão pro Git (binários grandes / asset de terceiros). Cada dev baixa localmente:

- **Soundfont de piano**: coloque um `.sf2` em `Equinox_Grand_Pianos/` (ou aponte outro com `-SoundFont`).
- **LilyPond** (Windows x64 portátil): <https://gitlab.com/lilypond/lilypond/-/releases> → `lilypond-2.x.y-mingw-x86_64.zip` → extraia em `tools/lilypond/`.
- **FluidSynth** (Windows x64 portátil): <https://github.com/FluidSynth/fluidsynth/releases> → `…-win10-x64-glib.zip` → extraia em `tools/fluidsynth/`.
- **ffmpeg**: `winget install Gyan.FFmpeg`

O `render.ps1` acha os `.exe` sozinho dentro de `tools/`.

> Se for versionar isto no Git, considere pôr `tools/` no `.gitignore` (são binários grandes) e deixar cada dev baixar pelos links acima.
