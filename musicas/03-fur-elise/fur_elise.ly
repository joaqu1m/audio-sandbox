\version "2.24.0"

%% ===========================================================================
%%  Für Elise — abertura (tema A)  |  L. v. Beethoven, 1810 (domínio público)
%%  EXEMPLO OFICIAL do fluxo LilyPond. Daqui sai partitura (PDF/PNG) e MIDI,
%%  e o render.ps1 transforma o MIDI em .mp3 no soundfont.
%%  Agora COM dinâmica e pedal — note como isso enriquece o áudio E a partitura.
%% ===========================================================================

\header {
  title    = "Für Elise — abertura (tema A)"
  composer = "L. v. Beethoven (1810) — domínio público"
  tagline  = ##f
}

%% --- MÃO DIREITA (melodia) — com DINÂMICA --------------------------------
%%  \p = piano, \f = forte, \< ... = crescendo, \> ... = decrescendo.
maoDireita = {
  \key a \minor
  \time 4/4
  \tempo 4 = 72
  \repeat unfold 2 {
    e''16\p\< dis'' e'' dis'' e'' b' d'' c''   % começa piano e vai crescendo...
    a'8 c' e' a'
    b'8\f e' gis' b'                            % ...até o forte
    c''2\>                                       % e decresce de volta
  }
  a'1\pp                                         % coda: Lá bem suave
  \bar "|."
}

%% --- MÃO ESQUERDA (acompanhamento) — com PEDAL ----------------------------
%%  \sustainOn / \sustainOff = pedal de sustain (aparece na partitura E no MIDI).
maoEsquerda = {
  \key a \minor
  \time 4/4
  \repeat unfold 2 {
    a,8 e a e a e a e                            % sob a corridinha: sem pedal (pra não borrar)
    e,8\sustainOn e gis e\sustainOff a,8\sustainOn e a e\sustainOff
  }
  <a, e a>1                                      % acorde final de Lá menor
  \bar "|."
}

\score {
  \new PianoStaff <<
    \new Staff = "rh" { \clef treble \maoDireita }
    \new Staff = "lh" { \clef bass   \maoEsquerda }
  >>
  \layout {}     % gravura (PDF/PNG)
  \midi {}       % MIDI (→ .mp3 via render.ps1)
}
