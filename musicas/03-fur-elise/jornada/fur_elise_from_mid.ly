% Lily was here -- automatically converted by midi2ly.py from C:\Users\joca\github.com\joaqu1m\audio-sandbox\demo\fur_elise.mid
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
  
  \tempo 4 = #10000000/131579 % ≈76
  
  \set Staff.instrumentName = "Fur Elise (tema A) - dominio publico"
  \skip 8*31 
}

trackAchannelB = \relative c {
  \voiceOne
  e''4*110/480 r4*10/480 dis4*110/480 r4*10/480 e4*110/480 r4*10/480 dis4*110/480 
  r4*10/480 e4*110/480 r4*10/480 b4*110/480 r4*10/480 d4*110/480 
  r4*10/480 c4*110/480 r4*10/480 a4*331/480 r4*29/480 c,4*110/480 
  r4*10/480 e4*110/480 r4*10/480 a4*110/480 r4*10/480 b4*331/480 
  r4*29/480 e,4*110/480 r4*10/480 gis4*110/480 r4*10/480 b4*110/480 
  r4*10/480 c4*331/480 r4*29/480 e4*110/480 r4*10/480 dis4*110/480 
  r4*10/480 e4*110/480 r4*10/480 dis4*110/480 r4*10/480 e4*110/480 
  r4*10/480 b4*110/480 r4*10/480 d4*110/480 r4*10/480 c4*110/480 
  r4*10/480 a4*331/480 r4*29/480 c,4*110/480 r4*10/480 e4*110/480 
  r4*10/480 a4*110/480 r4*10/480 b4*331/480 r4*29/480 e,4*110/480 
  r4*10/480 gis4*110/480 r4*10/480 b4*110/480 r4*10/480 c4*331/480 
  r4*29/480 e4*110/480 r4*10/480 dis4*110/480 r4*10/480 e4*110/480 
  r4*10/480 dis4*110/480 r4*10/480 e4*110/480 r4*10/480 b4*110/480 
  r4*10/480 d4*110/480 r4*10/480 c4*110/480 r4*10/480 a4*883/480 
}

trackAchannelBvoiceB = \relative c {
  \voiceTwo
  r2 a4. e a r16*5 a4. e a r16*5 a2 
}

trackAchannelBvoiceC = \relative c {
  \voiceFour
  r8*5 e4 r8 
  | % 2
  e4 r8 e4 r16*7 e4 r8 e4 r8 e4 
  | % 4
  r16*7 e4. 
}

trackAchannelBvoiceD = \relative c {
  \voiceThree
  r2. a'8 r4 gis8 r4 a8 r16*9 a8 r4 gis8 r4 a8 r16*9 a4 
}

trackA = <<
  \context Voice = voiceA \trackAchannelA
  \context Voice = voiceB \trackAchannelB
  \context Voice = voiceC \trackAchannelBvoiceB
  \context Voice = voiceD \trackAchannelBvoiceC
  \context Voice = voiceE \trackAchannelBvoiceD
>>


\score {
  <<
    \context Staff=trackA \trackA
  >>
  \layout {}
  \midi {}
}
