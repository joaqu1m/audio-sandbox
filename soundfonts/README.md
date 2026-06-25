# 🎹 Soundfonts

Os timbres usados pelo FluidSynth (`render.ps1`) para transformar MIDI em áudio.
Cada `.sf2` é um banco de instrumentos amostrados — é a **fonte** do som, do mesmo
jeito que o `.ly`/`.py` é a fonte da partitura.

> Os binários (`.sf2`) **não** vão pro Git (tamanho / licença de terceiros).
> Só são versionados: este `README.md`, o manifesto `soundfonts.json` e o `fetch.ps1`.

---

## Obter os soundfonts (um comando)

```powershell
.\soundfonts\fetch.ps1
```

O `fetch.ps1` lê o `soundfonts.json`, baixa o que falta, valida o header `.sf2`
(RIFF/sfbk) e **pula o que já existe**. O que não tem link direto (Equinox) vira
instrução de download manual na tela. Use `-Force` pra rebaixar tudo.

Adicionar um soundfont novo ao setup = adicionar uma entrada no `soundfonts.json`
(`name`, `file`, `url`, `notes`). Sem `url`? Deixe `null` e preencha `page`/`notes`
que o `fetch.ps1` mostra como passo manual.

---

## Catálogo

| Arquivo | Tamanho | Conteúdo | Bom pra | Download |
|---|---|---|---|---|
| `GeneralUser-GS.sf2` **(default)** | ~31 MB | **General MIDI completo**: 261 presets + 13 kits de bateria | Arranjos com **vários instrumentos** (cordas, sopros, baixo, órgão, sintetizadores, percussão) e também piano | automático (`fetch.ps1`) |
| `Equinox_Grand_Pianos.sf2` | ~92 MB | Piano de cauda dedicado (multi-camada) | Peças de **piano** com mais nuance que o piano GM | manual (sem link direto — ver `fetch.ps1`) |

Licenças: GeneralUser GS = permissiva (S. Christian Collins); Equinox = freeware (Omar Brown).

---

## Como usar

O default do `render.ps1` é o **GeneralUser GS** — já cobre piano e todos os
instrumentos GM. Pra usar outro timbre, passe `-SoundFont`:

```powershell
# piano dedicado (mais nuance), depois de baixar o Equinox manualmente
.\render.ps1 musicas\03-fur-elise\fur_elise.ly -SoundFont "soundfonts\Equinox_Grand_Pianos.sf2"
```

Com o GeneralUser GS, o `midiInstrument` do LilyPond soa de verdade — cada
`\new Staff` pode ser um instrumento diferente:

```lilypond
\new Staff { \set Staff.midiInstrument = "violin"        \melodia }
\new Staff { \set Staff.midiInstrument = "acoustic bass" \baixo }
\new Staff { \set Staff.midiInstrument = "flute"         \sopro }
```

Nomes válidos (GM): <https://lilypond.org/doc/v2.26/Documentation/notation/midi-instruments>.

---

## Quer mais variedade?

Adicione ao `soundfonts.json` (todos têm link direto, então o `fetch.ps1` baixa sozinho):

| Soundfont | Tamanho | Por que vale |
|---|---|---|
| **MuseScore_General** | ~210 MB (`.sf2`) / ~37 MB (`.sf3`) | GM mais rico, ótimo pra orquestral |
| **FluidR3_GM** | ~140 MB | O clássico GM do FluidSynth, referência da comunidade |
| **Sonatina Symphonic Orchestra** | ~500 MB | Orquestra dedicada (cordas/sopros/metais separados) |
