//
//  MusicSequenceTransposer.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox

class MusicSequenceTransposer {
    
    var sequence: MusicSequenceWrapper
    
    init(sequence: MusicSequenceWrapper) {
        setSequence(sequence)
    }
    
    func setSequence(sequence: MusicSequenceWrapper) -> Void {
        self.sequence = sequence
    }
    
    func transposeTrack(track: MusicTrack, dNote: UInt8) -> MusicTrack? {
        var iterator = MusicEventIteratorWrapper(track: track) // TODO use cloned track. create trackwrapper and implement clone using MusicTrackCopyInsert
        
        if iterator == nil {
            println("Failed to create Iterator")
            return nil
        }
        
        if iterator!.hasCurrent() {
            var result = transposeNote(iterator!, dNote: dNote)
            // continue if error???
        }
    }
    
    // make param instance variable?
    func transposeNote(iterator: MusicEventIteratorWrapper, dNote: UInt8) -> Bool {
        var noteMessage = iterator.getMIDINoteMessage()
        
        if noteMessage == nil {
            println("Could not get Note Message")
            return false
        }
        
        var newNote = noteMessage!.note + dNote
        
        // write note message to iterator (create function in iterator wrapper)
        
        return true
    }
    
    func transposeSequence(dNote: UInt8) -> MusicSequenceWrapper? {

        let trackCount = sequence.getTrackCount()
        
        if trackCount == nil {
            return nil
        }
        
        var currTrack = MusicTrack()
        var eventIterator = MusicEventIterator()
        
        for index in 0...(trackCount! - 1) {
            // get current track
            var status = MusicSequenceGetIndTrack(sequence.getSequence(), index, &currTrack)
            
            println("Track  \(index)")
            
            if status != noErr {
                println("Error in getting track")
            }
            
            // create event iterator
            status = NewMusicEventIterator(currTrack, &eventIterator)
            
            if status != noErr {
                println("Error in creating iterator")
            }
            
            // check if first event exists
            var hasCurrEvent = Boolean()
            status = MusicEventIteratorHasCurrentEvent(eventIterator, &hasCurrEvent)
            
            // transpose first event
            var eventTimeStamp = MusicTimeStamp()
            var eventType = MusicEventType()
            var eventData: UnsafePointer<()> = nil
            var eventDataSize = UInt32()
            
            // get event information
            var currMessage = getMIDINoteMessage(eventIterator)
            println("First Note: \(currMessage!.note)")
            
            // while has next event
            // change to next event
            // get curr Note value
            // add dNote to currNote value
            // set new Note value
            
            //            var hasNextEvent = Boolean()
            //            do {
            //
            //                status = MusicEventIteratorHasNextEvent(eventIterator, &hasNextEvent)
            //            } while(hasNextEvent != 0)
            
        }
        
        return sequence
    }
    
    //    func transposeNote(noteMessage: MIDINoteMessage, dNote: UInt8) -> MIDINoteMessage {
    //
    //        //TODO clone noteMessage with new note value
    //        noteMessage.note = noteMessage.note + dNote
    //        return noteMessage
    //    }

    
}
