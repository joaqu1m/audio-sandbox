#!/usr/bin/env python3
"""
Für Elise (tema A) -- versao NOTATION-CLEAN, pra converter pra partitura.
Obra em dominio publico (Beethoven, 1810).

Diferencas vs fur_elise.py (que saiu feio no midi2ly/MuseScore):
  1) DURACOES EXATAS  -> nada de *0.92. Notas coladas, sem pausas-fantasma.
  2) DUAS TRILHAS      -> mao direita e esquerda separadas = pauta dupla.
  3) FORMULA DE COMPASSO embutida (4/4) -> o conversor barra certo.
"""
import os
from mido import Message, MidiFile, MidiTrack, MetaMessage, bpm2tempo

TPB = 480
BPM = 80

_PC = {'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3, 'E': 4, 'F': 5,
       'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8, 'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11}

def m(name):
    i = 2 if name[1] in '#b' else 1
    return (int(name[i:]) + 1) * 12 + _PC[name[:i]]

def make_track(notes, name, base_vel, with_meta=False):
    """notes: lista de (pitch, dur) -- pitch pode ser nota, lista (acorde) ou None (pausa)."""
    tr = MidiTrack()
    if with_meta:
        tr.append(MetaMessage('set_tempo', tempo=bpm2tempo(BPM), time=0))
        tr.append(MetaMessage('time_signature', numerator=4, denominator=4, time=0))
    tr.append(MetaMessage('track_name', name=name, time=0))
    tr.append(Message('program_change', program=0, time=0))

    evs, t = [], 0.0
    for pitch, dur in notes:
        s, d = round(t * TPB), round(dur * TPB)   # duracao EXATA: note_off cola no proximo note_on
        if pitch is not None:
            for p in (pitch if isinstance(pitch, (list, tuple)) else [pitch]):
                pp = p if isinstance(p, int) else m(p)
                evs.append((s,     1, Message('note_on',  note=pp, velocity=base_vel)))
                evs.append((s + d, 0, Message('note_off', note=pp, velocity=0)))
        t += dur
    evs.sort(key=lambda e: (e[0], e[1]))
    last = 0
    for tick, _o, msg in evs:
        tr.append(msg.copy(time=tick - last)); last = tick
    return tr

# ----- mao direita: melodia (semicolcheias na corridinha, depois colcheias/notas longas) -----
RH = [
    ('E5', .25), ('D#5', .25), ('E5', .25), ('D#5', .25), ('E5', .25), ('B4', .25), ('D5', .25), ('C5', .25),
    ('A4', .5), ('C4', .5), ('E4', .5), ('A4', .5),
    ('B4', .5), ('E4', .5), ('G#4', .5), ('B4', .5),
    ('C5', 2.0),
    ('E5', .25), ('D#5', .25), ('E5', .25), ('D#5', .25), ('E5', .25), ('B4', .25), ('D5', .25), ('C5', .25),
    ('A4', .5), ('C4', .5), ('E4', .5), ('A4', .5),
    ('B4', .5), ('E4', .5), ('G#4', .5), ('B4', .5),
    ('C5', 2.0),
    ('A4', 4.0),                                   # coda: resolve em Lá
]

# ----- mao esquerda: acompanhamento em seminimas (Lá menor / Mi maior), bem comportado -----
LH = [
    ('A2', 1.0), ('E3', 1.0), ('A3', 1.0), ('E3', 1.0),
    ('E2', 1.0), ('G#3', 1.0), ('A2', 1.0), ('E3', 1.0),
    ('A2', 1.0), ('E3', 1.0), ('A3', 1.0), ('E3', 1.0),
    ('E2', 1.0), ('G#3', 1.0), ('A2', 1.0), ('E3', 1.0),
    (['A2', 'E3', 'A3'], 4.0),                     # coda: acorde de Lá menor segurado
]

mid = MidiFile(ticks_per_beat=TPB)
mid.tracks.append(make_track(RH, 'Mao direita', base_vel=84, with_meta=True))
mid.tracks.append(make_track(LH, 'Mao esquerda', base_vel=58))

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fur_elise_limpo.mid')
mid.save(out)
print(f'OK -> {out}  ({len(mid.tracks)} trilhas, ~{mid.length:.1f}s)')
