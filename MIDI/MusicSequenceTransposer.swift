//
//  MusicSequenceTransposer.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox

class MusicSequenceTransposer {
    
    var sequence: MusicSequenceWrapper = MusicSequenceWrapper()
    
    init(sequence: MusicSequenceWrapper) {
        setSequence(sequence)
    }
    
    func setSequence(sequence: MusicSequenceWrapper) -> Void {
        self.sequence = sequence
    }
    
    func getSequence() -> MusicSequenceWrapper {
        return sequence
    }
    
    func transposeSequence(dNote: UInt8) -> MusicSequenceWrapper? {
        let trackCount = sequence.getTrackCount()
        
        if trackCount == nil {
            return nil
        }
        
        var currTrack = MusicTrack()
        var eventIterator = MusicEventIterator()
        
        for index in 0...(trackCount! - 1) {
            var transposedTrack = transposeTrack(index, dNote: dNote)
            
            if transposedTrack == nil {
                return nil
            }
        }
        
        return getSequence()
    }
    
    func transposeTrack(index: UInt32, dNote: UInt8) -> MusicTrack? {
        var track = MusicTrack()
        var status = MusicSequenceGetIndTrack(sequence.getSequence(), index, &track)
        
        if status != noErr {
            println("Error in getting track")
            return nil
        }
        
        return transposeTrack(track, dNote: dNote)
    }
    
    private func transposeTrack(track: MusicTrack, dNote: UInt8) -> MusicTrack? {
        var iterator = MusicEventIteratorWrapper(track: track)
        
        if iterator == nil {
            println("Failed to create Iterator")
            return nil
        }
        
        var hasCurrEvent = iterator!.hasCurrent()
        while hasCurrEvent {
            var result = transposeNote(iterator!, dNote: dNote)
            
            if !result {
                return nil
            }
            
            if !iterator!.next() {
                hasCurrEvent = false
            }
        }
        
        return track
    }
    
    private func transposeNote(iterator: MusicEventIteratorWrapper, dNote: UInt8) -> Bool {
        var noteMessage = iterator.getMIDINoteMessage()
        
        if noteMessage == nil {
            println("Could not get Note Message")
            return false
        }
        
        var newNote = noteMessage!.note + dNote
        var newNoteMessage = MIDINoteMessage(channel: noteMessage!.channel, note: newNote, velocity: noteMessage!.velocity, releaseVelocity: noteMessage!.releaseVelocity, duration: noteMessage!.duration)
        
        return iterator.setMIDINoteMessage(newNoteMessage)
    }

}
