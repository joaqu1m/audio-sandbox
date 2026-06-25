\version "2.24.0"

%% ===========================================================================
%%  "Quarta de Sandbox" — pecinha alegre de teste.
%%  Arranjo multi-instrumental que exercita o GeneralUser-GS (General MIDI):
%%  flauta + cordas + piano + baixo + bateria, cada um num timbre diferente.
%%
%%  Renderize com o soundfont General MIDI (pra os timbres soarem de verdade):
%%    .\render.ps1 musicas\04-sandbox-quarta\sandbox-quarta.ly -SoundFont "soundfonts\GeneralUser-GS.sf2"
%%
%%  Forma: 8 compassos repetidos (\repeat volta 2 -> toca 2x no MIDI).
%%  Harmonia: C - G - Am - F - C - G - F - C  (o velho I-V-vi-IV).
%% ===========================================================================

global = {
  \key c \major
  \time 4/4
  \tempo 4 = 120
}

%% ---- FLAUTA (melodia) -----------------------------------------------------
flauta = {
  \global
  \repeat volta 2 {
    e''4\mf g'' e'' c''  |   % C
    d''4    g'' d'' b'   |   % G
    c''4    e'' c'' a'   |   % Am
    f''4    a'' f'' c''  |   % F
    e''4    g'' e'' c''  |   % C
    d''4    b'  d'' g''  |   % G
    a'4     c'' f'' a'   |   % F
    c''1                 |   % C
  }
}

%% ---- CORDAS (colchao harmonico, semibreves) -------------------------------
cordas = {
  \global
  \repeat volta 2 {
    <c' e' g'>1   |   % C
    <b d' g'>1    |   % G
    <a c' e'>1    |   % Am
    <a c' f'>1    |   % F
    <c' e' g'>1   |   % C
    <b d' g'>1    |   % G
    <a c' f'>1    |   % F
    <c' e' g'>1   |   % C
  }
}

%% ---- PIANO: mao direita (comping em colcheias) ----------------------------
pianoRH = {
  \global
  \repeat volta 2 {
    <c' e' g'>8\p q q q q q q q  |   % C
    <b d' g'>8   q q q q q q q  |   % G
    <a c' e'>8   q q q q q q q  |   % Am
    <a c' f'>8   q q q q q q q  |   % F
    <c' e' g'>8  q q q q q q q  |   % C
    <b d' g'>8   q q q q q q q  |   % G
    <a c' f'>8   q q q q q q q  |   % F
    <c' e' g'>2  q             |   % C
  }
}

%% ---- PIANO: mao esquerda (raiz + quinta) ----------------------------------
pianoLH = {
  \global
  \repeat volta 2 {
    c2 g    |   % C
    g,2 d   |   % G
    a,2 e   |   % Am
    f,2 c   |   % F
    c2 g    |   % C
    g,2 d   |   % G
    f,2 c   |   % F
    c1      |   % C
  }
}

%% ---- BAIXO acustico (pulso raiz-quinta) -----------------------------------
baixo = {
  \global
  \repeat volta 2 {
    c,4 g, c, g,    |   % C
    g,,4 d, g,, d,  |   % G
    a,,4 e, a,, e,  |   % Am
    f,,4 c, f,, c,  |   % F
    c,4 g, c, g,    |   % C
    g,,4 d, g,, d,  |   % G
    f,,4 c, f,, c,  |   % F
    c,1             |   % C
  }
}

%% ---- BATERIA --------------------------------------------------------------
ritmo = \drummode {
  \repeat volta 2 {
    \repeat unfold 7 { <bd hh>8 hh <sn hh> hh <bd hh> hh <sn hh> hh }
    <bd cymc>8 hh <sn hh> hh <bd hh> hh <sn hh> hh
  }
}

\header {
  title    = "Quarta de Sandbox"
  subtitle = "experimento multi-instrumental (General MIDI)"
  composer = "audio-sandbox"
  tagline  = ##f
}

\score {
  <<
    \new Staff \with { instrumentName = "Flauta" midiInstrument = "flute" }
      { \clef treble \flauta }
    \new Staff \with { instrumentName = "Cordas" midiInstrument = "string ensemble 1" }
      { \clef treble \cordas }
    \new PianoStaff \with { instrumentName = "Piano" }
    <<
      \set PianoStaff.midiInstrument = "acoustic grand"
      \new Staff { \clef treble \pianoRH }
      \new Staff { \clef bass   \pianoLH }
    >>
    \new Staff \with { instrumentName = "Baixo" midiInstrument = "acoustic bass" }
      { \clef bass \baixo }
    \new DrumStaff \with { instrumentName = "Bateria" }
      { \ritmo }
  >>
  \layout {}
  \midi {}
}
