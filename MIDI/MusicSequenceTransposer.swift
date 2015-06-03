//
//  MusicSequenceTransposer.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox

// be wary of drum track (MIDI std channel 10)
// TODO ignore drum track
func TransposeSequence(sequence: MusicSequence, transpose: Int8) {
    let trackCount = SequenceGetTrackCount(sequence)
    if let trackCount = trackCount {
        for index in 0..<trackCount {
            var currTrack = SequenceGetTrackByIndex(sequence, index)!
            TransposeTrack(currTrack, transpose)
        }
    }
}

func TransposeTrack(sequence: MusicSequence, index: UInt32, transpose: Int8) {
    let track = SequenceGetTrackByIndex(sequence, index)
    if let track = track {
        TransposeTrack(track, transpose)
    }
}

//func TransposeTrack(track: MusicTrack, transpose: Int8) {
//    let iterator = NewIterator(track)
//    if let iterator = iterator {
//        var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
//        while  hasCurrentEvent {
//            // transpose note
//            let noteEvent = IteratorGetCurrentNoteEvent(iterator)
//            if let noteEvent = noteEvent {
//                var newNote = Int8(noteEvent.note) + transpose
//                if newNote < 0 || newNote > 127{
//                    println("Transposing out of note range.")
//                }
//                let newNoteEvent = MIDINoteMessage(channel: noteEvent.channel, note: UInt8(newNote), velocity: noteEvent.velocity,
//                    releaseVelocity: noteEvent.releaseVelocity, duration: noteEvent.duration)
//                IteratorSetCurrentNoteEvent(iterator, newNoteEvent)
//            }
//            hasCurrentEvent = IteratorToNextEvent(iterator)
//        }
//    }
//}

func TransposeTrack(track: MusicTrack, transpose: Int8) {
    func transposeNote(event: IteratorEvent) -> IteratorEvent {
        if let note = EventToNote(event) {
            if NoteIsValid(note, transpose) {
                let transposedNote = UInt8(NewNote(note, transpose))
                return NoteToEvent(MIDINoteMessage(channel: note.channel,
                                                   note: transposedNote,
                                                   velocity: note.velocity,
                                                   releaseVelocity: note.releaseVelocity,
                                                   duration: note.duration))
            }
        }
        return event
    }
    
    let iterator = NewIterator(track)
    if let iterator = iterator {
        IteratorMap(iterator, transposeNote)
    }
}

func NoteIsValid(note: MIDINoteMessage, transpose: Int8) -> Bool {
    return (NewNote(note, transpose) >= 0) && (NewNote(note, transpose) <= 127)
}

func NewNote(note: MIDINoteMessage, transpose: Int8) -> Int8 {
    return Int8(note.note) + transpose
}