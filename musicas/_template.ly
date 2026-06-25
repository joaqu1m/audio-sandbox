\version "2.24.0"

%% ===========================================================================
%%  TEMPLATE — ponto de partida pra uma música nova.
%%  1) copie pra  musicas/NN-nome/nome.ly
%%  2) componha (veja a sintaxe no README.md)
%%  3) rode      .\render.ps1 musicas\NN-nome\nome.ly
%% ===========================================================================

\header {
  title    = "Título da peça"
  composer = "Seu nome"
  tagline  = ##f
}

maoDireita = {
  \key c \major
  \time 4/4
  \tempo 4 = 96
  c'4 d' e' f' | g'1 |
}

maoEsquerda = {
  \key c \major
  \time 4/4
  c2 g, | c1 |
}

\score {
  \new PianoStaff <<
    \new Staff = "rh" { \clef treble \maoDireita }
    \new Staff = "lh" { \clef bass   \maoEsquerda }
  >>
  \layout {}
  \midi {}
}
