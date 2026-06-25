#!/usr/bin/env python3
"""
Für Elise (Beethoven, 1810) -- tema A, transcrito via codigo.
Obra em DOMINIO PUBLICO: pode ser reproduzida livremente.

Objetivo: provar que o pipeline (codigo -> MIDI -> FluidSynth + .sf2)
reproduz fielmente uma musica REAL e reconhecivel, nao so peca original.
Mesmo fluxo de sempre; sai no piano Steinway D do seu soundfont.
"""
import os
from mido import Message, MidiFile, MidiTrack, MetaMessage, bpm2tempo

TPB = 480
BPM = 76    # "Poco moto" -- andamento leve

_PC = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5,
       'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11}

def m(name):
    i = 2 if name[1] in '#b' else 1
    return (int(name[i:]) + 1) * 12 + _PC[name[:i]]

events = []

def add_note(pitch, start_beat, dur_beat, vel=70):
    p = pitch if isinstance(pitch, int) else m(pitch)
    s, d = round(start_beat * TPB), round(dur_beat * TPB)
    events.append((s,     1, Message('note_on',  note=p, velocity=vel)))
    events.append((s + d, 0, Message('note_off', note=p, velocity=0)))

def pedal(start_beat, down):
    t = round(start_beat * TPB)
    events.append((t, 0, Message('control_change', control=64, value=127 if down else 0)))

# ---------- cursor de tempo (em batidas de seminima) ----------
t = 0.0

def rh(note, dur, vel=84):          # mao direita (melodia)
    global t
    add_note(note, t, dur * 0.92, vel)
    t += dur

def lh(at, notes, span=1.5):        # mao esquerda: arpejo ascendente, com pedal
    pedal(at, True)
    for i, n in enumerate(notes):
        add_note(n, at + i * 0.5, span - i * 0.5, 56 - i * 2)
    pedal(at + span - 0.05, False)

def run():                          # o famoso "Mi Re# Mi Re# Mi Si Re Do" (mao direita sozinha)
    for n in ['E5', 'D#5', 'E5', 'D#5', 'E5', 'B4', 'D5', 'C5']:
        rh(n, 0.25, 80)

def statement():
    run()
    lh(t, ['A2', 'E3', 'A3'])       # Lá menor
    rh('A4', 0.75, 86)
    rh('C4', 0.25); rh('E4', 0.25); rh('A4', 0.25)
    lh(t, ['E2', 'E3', 'G#3'])      # Mi maior (V)
    rh('B4', 0.75, 86)
    rh('E4', 0.25); rh('G#4', 0.25); rh('B4', 0.25)
    lh(t, ['A2', 'E3', 'A3'])       # Lá menor
    rh('C5', 0.75, 86)

# ---------- monta o tema A (duas vezes) + final ----------
statement()
statement()

run()                                # coda: resolve em Lá longo
at = t
pedal(at, True)
for i, n in enumerate(['A2', 'E3', 'A3']):
    add_note(n, at + i * 0.5, 2.0 - i * 0.5, 54)
rh('A4', 2.0, 82)
pedal(t - 0.05, False)

# ---------- exporta MIDI ----------
mid = MidiFile(ticks_per_beat=TPB)
tr = MidiTrack(); mid.tracks.append(tr)
tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(BPM), time=0))
tr.append(MetaMessage('track_name', name='Fur Elise (tema A) - dominio publico', time=0))
tr.append(Message('program_change', program=0, time=0))  # preset 0 = Steinway D

events.sort(key=lambda e: (e[0], e[1]))
last = 0
for tick, _ordem, msg in events:
    tr.append(msg.copy(time=tick - last))
    last = tick

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fur_elise.mid')
mid.save(out)
print(f'OK -> {out}  ({len(events)} eventos, ~{mid.length:.1f}s)')
