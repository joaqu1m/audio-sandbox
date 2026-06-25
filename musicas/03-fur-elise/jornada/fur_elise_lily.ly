\version "2.24.0"

%% ===========================================================================
%%  Für Elise — abertura (tema A)  |  L. v. Beethoven, 1810 (domínio público)
%%  Escrito NATIVAMENTE em LilyPond: o texto abaixo É a partitura-fonte.
%%  Daqui sai PDF/PNG (gravura) e MIDI (\midi{}) de uma vez só.
%% ===========================================================================

\header {
  title    = "Für Elise — abertura (tema A)"
  composer = "L. v. Beethoven (1810) — domínio público"
  tagline  = ##f          % remove o rodapé padrão do LilyPond
}

%% --- MÃO DIREITA (melodia) -------------------------------------------------
%%  Oitavas absolutas: c' = dó central (C4); cada ' sobe uma oitava.
%%  Durações: 16 = semicolcheia, 8 = colcheia, 4 = semínima, 2 = mínima, 1 = semibreve.
maoDireita = {
  \key a \minor          % armadura de Lá menor (sem sustenidos/bemóis)
  \time 4/4
  \tempo 4 = 72
  \repeat unfold 2 {     % toca o bloco 2x (vale também no MIDI)
    %    a corridinha famosa: Mi Ré# Mi Ré# Mi Si Ré Dó
    e''16 dis'' e'' dis'' e'' b' d'' c''
    a'8 c' e' a'          % arpejo de Lá menor subindo
    b'8 e' gis' b'        % arpejo de Mi maior
    c''2                  % pousa em Dó
  }
  a'1                     % coda: Lá segurado (semibreve)
  \bar "|."
}

%% --- MÃO ESQUERDA (acompanhamento Alberti em colcheias) --------------------
%%  É isto que devolve o "preenchimento" que faltava na versão podada.
maoEsquerda = {
  \key a \minor
  \time 4/4
  \repeat unfold 2 {
    a,8 e a e a e a e          % Lá menor quebrado
    e,8 e gis e  a,8 e a e     % Mi maior, depois Lá menor
  }
  <a, e a>1                    % acorde de Lá menor segurado
  \bar "|."
}

%% --- a partitura: duas pautas num sistema de piano -------------------------
\score {
  \new PianoStaff <<
    \new Staff = "rh" { \clef treble \maoDireita }
    \new Staff = "lh" { \clef bass   \maoEsquerda }
  >>
  \layout {}               % gera a gravura (PDF/PNG)
  \midi {}                 % gera também um .mid pra tocar no soundfont
}
