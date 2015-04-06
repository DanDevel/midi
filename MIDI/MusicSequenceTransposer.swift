//
//  MusicSequenceTransposer.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox

// be wary of drum track (MIDI std channel 10)
func TransposeSequence(sequence: MusicSequence, transpose: Int8) -> MusicSequence? {
    let trackCount = SequenceGetTrackCount(sequence)
    var transposedSequence = NewSequence()
    if let transposedSequence = transposedSequence {
        if let trackCount = trackCount {
            for index in 0..<trackCount {
                let currTrack = SequenceGetTrackByIndex(sequence, index)
                if let currTrack = currTrack {
                    let transposedTrack = TransposeTrack(currTrack, transpose)
                    if let transposedTrack = transposedTrack  {
                        SequenceAddTrack(transposedSequence, transposedTrack)
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
        return transposedSequence
    }
    
    return nil
}

func TransposeTrack(sequence: MusicSequence, index: UInt32, transpose: Int8) -> MusicTrack? {
    let track = SequenceGetTrackByIndex(sequence, index)
    if let track = track {
        return TransposeTrack(track, transpose)
    }
    return nil
}

func TransposeTrack(track: MusicTrack, transpose: Int8) -> MusicTrack? {
    var transposedTrack = TrackClone(track)
    if let transposedTrack = transposedTrack {
        let iterator = NewIterator(transposedTrack)
        if let iterator = iterator {
            var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
            while  hasCurrentEvent {
                // transpose note
                let noteEvent = IteratorGetCurrentNoteEvent(iterator)
                if let noteEvent = noteEvent {
                    var newNote = Int8(noteEvent.note) + transpose
                    if newNote < 0 || newNote > 127{
                        println("Transposing out of note range.")
                        return nil
                    }
                    let newNoteEvent = MIDINoteMessage(channel: noteEvent.channel, note: UInt8(newNote), velocity: noteEvent.velocity,
                        releaseVelocity: noteEvent.releaseVelocity, duration: noteEvent.duration)
                    IteratorSetCurrentNoteEvent(iterator, newNoteEvent)
                }
                hasCurrentEvent = IteratorToNextEvent(iterator)
            }
            return transposedTrack
        }
    }
    return nil
}
