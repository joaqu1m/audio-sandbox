#!/usr/bin/env python3
"""
Demo: compor musica como CODIGO -> gerar um MIDI editavel.

A ideia: aqui voce escreve as NOTAS (nao o audio). O resultado e um .mid,
um asset minusculo e 100% editavel. Quem vira "som de verdade" e o FluidSynth,
tocando esse MIDI atraves de QUALQUER soundfont .sf2 (no nosso caso, o piano
Steinway D do Equinox_Grand_Pianos.sf2).

Peca: ~30s de piano em Lá menor, progressao vi-IV-I-V (Am - F - C - G),
estilo trilha indie melancolica. Troque as notas/acordes e rode de novo.
"""
import os
from mido import Message, MidiFile, MidiTrack, MetaMessage, bpm2tempo

TPB = 480   # ticks por batida (resolucao temporal)
BPM = 72    # andamento: lento e emotivo

# ---------- helper: nome de nota -> numero MIDI (C4 = 60 = do central) ----------
_PC = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5,
       'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11}

def m(name):
    """'A4' -> 69, 'C#5' -> 73, 'Bb2' -> 46"""
    i = 2 if name[1] in '#b' else 1
    return (int(name[i:]) + 1) * 12 + _PC[name[:i]]

# ---------- agenda de eventos em tempo ABSOLUTO (depois vira delta-time) ----------
events = []  # cada item: (tick_absoluto, ordem, Message)  ordem 0 = antes de 1

def add_note(pitch, start_beat, dur_beat, vel=70):
    p = pitch if isinstance(pitch, int) else m(pitch)
    s, d = round(start_beat * TPB), round(dur_beat * TPB)
    events.append((s,     1, Message('note_on',  note=p, velocity=vel)))
    events.append((s + d, 0, Message('note_off', note=p, velocity=0)))

def pedal(start_beat, down):
    t = round(start_beat * TPB)
    events.append((t, 0, Message('control_change', control=64, value=127 if down else 0)))

# ---------- harmonia: (baixo, [notas do arpejo]) por compasso ----------
PROG = [
    ('A2', ['A3', 'C4', 'E4', 'A4']),   # Lá menor  (vi)
    ('F2', ['F3', 'A3', 'C4', 'F4']),   # Fá maior  (IV)
    ('C3', ['C4', 'E4', 'G4', 'C5']),   # Dó maior  (I)
    ('G2', ['G3', 'B3', 'D4', 'G4']),   # Sol maior (V)
]

def bar_accomp(bar, base_vel):
    """Baixo sustentado + arpejo de 8 colcheias, com pedal de sustain."""
    t0 = bar * 4.0
    baixo, arp = PROG[bar % 4]
    pedal(t0, True)                        # pedal desce
    add_note(baixo, t0, 3.9, base_vel)     # grave segura o compasso
    for i, nota in enumerate(arp + arp):   # 8 colcheias
        acento = 8 if i % 2 == 0 else 0
        add_note(nota, t0 + i * 0.5, 0.55, base_vel + acento)
    pedal(t0 + 3.88, False)                # solta o pedal (pedaleio legato)

# ---------- melodia (mao direita) sobre a MESMA progressao ----------
MELODIA = {
    4: [('A4', 0, 1), ('C5', 1, 1), ('E5', 2, 2)],
    5: [('F5', 0, 1.5), ('E5', 1.5, 0.5), ('C5', 2, 2)],
    6: [('D5', 0, 1), ('E5', 1, 1), ('G5', 2, 2)],
    7: [('D5', 0, 1), ('B4', 1, 1), ('G4', 2, 2)],
}

def bar_melody(bar):
    t0 = bar * 4.0
    for nome, off, dur in MELODIA[bar]:
        add_note(nome, t0 + off, dur, vel=92)

# ---------- monta a peca ----------
for bar in range(0, 4):          # intro: so acompanhamento, crescendo suave
    bar_accomp(bar, base_vel=48 + bar * 4)
for bar in range(4, 8):          # tema: acompanhamento + melodia
    bar_accomp(bar, base_vel=64)
    bar_melody(bar)

FIN = 8 * 4.0                    # acorde final de Dó maior segurando (resolucao)
pedal(FIN, True)
for p, v in [('C3', 55), ('G3', 50), ('E4', 55), ('G4', 55), ('C5', 60), ('E5', 66)]:
    add_note(p, FIN, 6, v)

# ---------- exporta o MIDI ----------
mid = MidiFile(ticks_per_beat=TPB)
tr = MidiTrack(); mid.tracks.append(tr)
tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(BPM), time=0))
tr.append(MetaMessage('track_name', name='Trilha demo - piano', time=0))
tr.append(Message('program_change', program=0, time=0))  # preset 0 do sf2 = Steinway D

events.sort(key=lambda e: (e[0], e[1]))
last = 0
for tick, _ordem, msg in events:
    tr.append(msg.copy(time=tick - last))
    last = tick

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'trilha.mid')
mid.save(out)
print(f'OK -> {out}  ({len(events)} eventos, ~{mid.length:.1f}s de musica)')
