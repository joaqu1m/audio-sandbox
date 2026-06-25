#!/usr/bin/env python3
"""
Peca AMBIENT ORIGINAL, no espirito das trilhas calmas de exploracao
(acordes lush com 7a/9a, arpejos hipnoticos, clima contemplativo).
NAO e nenhuma musica existente -- e composta aqui, do zero, em codigo.

Mesmo pipeline de sempre: codigo -> MIDI editavel -> FluidSynth + .sf2.
Como seu soundfont so tem piano, sai um piano ambient. Com um soundfont
de pads/cordas, a MESMA peca floresce em textura sem mudar a logica.
"""
import os
from mido import Message, MidiFile, MidiTrack, MetaMessage, bpm2tempo

TPB = 480   # ticks por batida
BPM = 88    # lento, espacoso

# ---------- nome de nota -> numero MIDI (C4 = 60) ----------
_PC = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5,
       'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11}

def m(name):
    i = 2 if name[1] in '#b' else 1
    return (int(name[i:]) + 1) * 12 + _PC[name[:i]]

# ---------- agenda de eventos (tempo absoluto -> delta) ----------
events = []

def add_note(pitch, start_beat, dur_beat, vel=70):
    p = pitch if isinstance(pitch, int) else m(pitch)
    s, d = round(start_beat * TPB), round(dur_beat * TPB)
    events.append((s,     1, Message('note_on',  note=p, velocity=vel)))
    events.append((s + d, 0, Message('note_off', note=p, velocity=0)))

def pedal(start_beat, down):
    t = round(start_beat * TPB)
    events.append((t, 0, Message('control_change', control=64, value=127 if down else 0)))

# ---------- harmonia lush: (baixo, [vozes do acorde], [celula do arpejo]) ----------
PROG = [
    ('C2', ['E4', 'G4', 'B4', 'D5'], ['C3', 'G3', 'E4', 'B4']),  # Cmaj9
    ('A2', ['C4', 'E4', 'G4', 'C5'], ['A3', 'E4', 'C4', 'G4']),  # Am7
    ('F2', ['A3', 'C4', 'E4', 'A4'], ['F3', 'C4', 'A3', 'E4']),  # Fmaj7
    ('G2', ['B3', 'D4', 'E4', 'G4'], ['G3', 'D4', 'B3', 'E4']),  # G6
]

def pad(bar, vel):
    """Acorde inteiro segurado (textura de 'almofada')."""
    t0 = bar * 4.0
    baixo, vozes, _ = PROG[bar % 4]
    pedal(t0, True)
    add_note(baixo, t0, 3.9, vel)
    for v in vozes:
        add_note(v, t0, 3.9, vel - 6)
    pedal(t0 + 3.85, False)

def arp(bar, vel):
    """Baixo + arpejo de 8 colcheias fluindo pelo acorde."""
    t0 = bar * 4.0
    baixo, _, cell = PROG[bar % 4]
    pedal(t0, True)
    add_note(baixo, t0, 3.9, vel)
    for i, n in enumerate(cell + cell):
        add_note(n, t0 + i * 0.5, 0.6, vel + (6 if i % 2 == 0 else -2))
    pedal(t0 + 3.85, False)

# ---------- melodia flutuante (original), compassos 4..11 ----------
MELODIA = {
    4:  [('E5', 0, 2), ('D5', 2, 2)],
    5:  [('C5', 0, 3), ('B4', 3, 1)],
    6:  [('A4', 0, 2), ('C5', 2, 2)],
    7:  [('B4', 0, 2), ('D5', 2, 1), ('G4', 3, 1)],
    8:  [('G5', 0, 1.5), ('E5', 1.5, 2.5)],
    9:  [('E5', 0, 2), ('C5', 2, 2)],
    10: [('F5', 0, 2), ('E5', 2, 1), ('C5', 3, 1)],
    11: [('D5', 0, 4)],
}

# ---------- monta a peca ----------
for bar in range(0, 4):              # intro: pads suaves, fade-in (crescendo)
    pad(bar, vel=38 + bar * 5)
for bar in range(4, 12):             # tema: arpejo + melodia
    arp(bar, vel=58)
    for nome, off, dur in MELODIA.get(bar, []):
        add_note(nome, bar * 4.0 + off, dur, vel=86)

FIN = 12 * 4.0                       # outro: Cmaj9 segurando, decaindo
pedal(FIN, True)
for p, v in [('C2', 46), ('C3', 44), ('E4', 50), ('G4', 50), ('B4', 54), ('D5', 56), ('E5', 60)]:
    add_note(p, FIN, 8, v)

# ---------- exporta MIDI ----------
mid = MidiFile(ticks_per_beat=TPB)
tr = MidiTrack(); mid.tracks.append(tr)
tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(BPM), time=0))
tr.append(MetaMessage('track_name', name='Ambient - exploracao (original)', time=0))
tr.append(Message('program_change', program=0, time=0))  # preset 0 = Steinway D

events.sort(key=lambda e: (e[0], e[1]))
last = 0
for tick, _ordem, msg in events:
    tr.append(msg.copy(time=tick - last))
    last = tick

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ambient.mid')
mid.save(out)
print(f'OK -> {out}  ({len(events)} eventos, ~{mid.length:.1f}s)')
