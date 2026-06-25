% Lily was here -- automatically converted by midi2ly.py from C:\Users\joca\github.com\joaqu1m\audio-sandbox\demo\fur_elise_limpo.mid
\version "2.14.0"

\layout {
  \context {
    \Voice
    \remove Note_heads_engraver
    \consists Completion_heads_engraver
    \remove Rest_engraver
    \consists Completion_rest_engraver
  }
}

trackAchannelA = {
  
  \tempo 4 = 80
  
  \time 4/4
  
  \set Staff.instrumentName = "Mao direita"
  \skip 1*5 
}

trackAchannelB = \relative c {
  e''16 dis e dis e b d c a8 c, e a 
  | % 2
  b e, gis b c2 
  | % 3
  e16 dis e dis e b d c a8 c, e a 
  | % 4
  b e, gis b c2 
  | % 5
  a1 
  | % 6
  
}

trackA = <<
  \context Voice = voiceA \trackAchannelA
  \context Voice = voiceB \trackAchannelB
>>


trackBchannelA = {
  
  \set Staff.instrumentName = "Mao esquerda"
  \skip 1*5 
}

trackBchannelB = \relative c {
  a4 e' a e 
  | % 2
  e, gis' a, e' 
  | % 3
  a, e' a e 
  | % 4
  e, gis' a, e' 
  | % 5
  <a, e' a >1 
  | % 6
  
}

trackB = <<

  \clef bass
  
  \context Voice = voiceA \trackBchannelA
  \context Voice = voiceB \trackBchannelB
>>


\score {
  <<
    \context Staff=trackA \trackA
    \context Staff=trackB \trackB
  >>
  \layout {}
  \midi {}
}
