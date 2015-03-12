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
    
    var copy_sequence: MusicSequenceWrapper? //make sure transposeTrack uses proper track in copy_sequence
    
    init(sequence: MusicSequenceWrapper) {
        setSequence(sequence)
    }
    
    func setSequence(sequence: MusicSequenceWrapper) -> Void {
        self.sequence = sequence
    }
    
    func getSequence() -> MusicSequenceWrapper {
        return sequence
    }
    
    // return new sequence containing transposed tracks
    // be wary of drum track (MIDI std channel 10)
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
        var track = sequence.getTrack(index)
        
        if track == nil {
            return nil
        }
        
        return transposeTrack(track!, dNote: dNote)
    }
    
    private func transposeTrack(track: MusicTrack, dNote: UInt8) -> MusicTrack? {
        var dummySequence = MusicSequenceWrapper.newSequence()!; // error checking?
        
        var transposedTrack = MusicTrack()
        
        var status = MusicSequenceNewTrack(dummySequence, &transposedTrack)
        
        if status != noErr {
            println("could not make new track")
            return nil
        }
        
        // TODO get length of original track
//        var data = UnsafeMutablePointer<Void>()
//        var length = UnsafeMutablePointer<UInt32>()
//        status = MusicTrackGetProperty(track, UInt32(kSequenceTrackProperty_TrackLength), data, length)
//        if status != noErr {
//            println("Could not get property")
//            return nil
//        }
//        var d = UnsafeMutablePointer<UInt32>(data)
//        var len = MusicTimeStamp(d.memory)
        
        // copy original track to other track
        status = MusicTrackCopyInsert(track, 0, 20, transposedTrack, 0)  // TODO use length instead of 20
        
        if status != noErr {
            println("Could not copy track")
            return nil
        }
        
        // create iterator
        var iterator = MusicEventIteratorWrapper(track: transposedTrack)
        
        if iterator == nil {
            println("Failed to create Iterator")
            return nil
        }
        
        // iterate over each MIDI event
        var hasCurrEvent = iterator!.hasCurrent()
        while hasCurrEvent {
            // transpose the current event
            var result = transposeNote(iterator!, dNote: dNote)
            
//            if !result {
//                return nil
//            }
            
            if !iterator!.next() {
                hasCurrEvent = false
            }
        }
        
        return transposedTrack  //does track need to be detached from original sequence?
    }
    
    // TODO  false doesn't necessarily mean error.....rethink error handling here
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
