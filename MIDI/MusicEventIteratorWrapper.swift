//
//  MusicEventIteratorWrapper.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox

class MusicEventIteratorWrapper {
    
    var iterator = MusicEventIterator()
    
    init?(track: MusicTrack) {
        var iterator = MusicEventIteratorWrapper.newIterator(track)
        
        if iterator == nil {
            return nil
        }
        
        setIterator(iterator!)
    }
    
    class func newIterator(track: MusicTrack) -> MusicEventIterator? {
        var iterator = MusicEventIterator()
        var status = NewMusicEventIterator(track, &iterator)
        
        if status != noErr {
            println("Failed to create new iterator")
            return nil
        }
        
        return iterator
    }
    
    func setIterator(iterator: MusicEventIterator) {
        self.iterator = iterator
    }
    
    func hasNext() -> Bool {
        var hasNext = Boolean()
        var status = MusicEventIteratorHasNextEvent(iterator, &hasNext)
        
        if status != noErr {
            println("Could not check for next event.")
            return false
        }
        
        return hasNext != 0
    }
    
    func hasCurrent() -> Bool {
        var hasCurrent = Boolean()
        var status = MusicEventIteratorHasCurrentEvent(iterator, &hasCurrent)
        
        if status != noErr {
            println("Could not check for next event.")
            return false
        }
        
        return hasCurrent != 0
    }
    
    // Return Error instead?
    func next() -> Bool {
        if !hasNext() {
            return false
        }
        
        var status = MusicEventIteratorNextEvent(iterator)
        
        if status != noErr {
            println("Failed to get Next Event")
            return false
        }
        
        return true
    }
    
    func nextEvent() -> (timeStamp: MusicTimeStamp, type: MusicEventType, data: UnsafePointer<()>, dataSize: UInt32)? {
        if next() {
            return getIteratorEvent()
        }
        
        return nil
    }
    
    func nextMIDINoteMessage() -> MIDINoteMessage? {
        if next() {
            return getMIDINoteMessage()
        }
        
        return nil
    }
    
    // assumes current event is available
    func getIteratorEvent() -> (timeStamp: MusicTimeStamp, type: MusicEventType, data: UnsafePointer<()>, dataSize: UInt32)? {
        var timeStamp = MusicTimeStamp()
        var type = MusicEventType()
        var data: UnsafePointer<()> = nil
        var dataSize = UInt32()
        
        var status = MusicEventIteratorGetEventInfo(iterator, &timeStamp, &type, &data, &dataSize)
        
        if status != noErr {
            return nil
        }
        
        return (timeStamp, type, data, dataSize)
    }
    
    func setIteratorEvent(type: MusicEventType, data: UnsafePointer<()>) -> Bool {
        var status = MusicEventIteratorSetEventInfo(iterator, type, data)
        
        if status != noErr {
            println("Could not set event info")
            return false
        }
        
        return true
    }
    
    // assumes current event is available
    func getMIDINoteMessage() -> MIDINoteMessage? {
        var event = getIteratorEvent()
        
        if event == nil  || event!.type != MusicEventType(kMusicEventType_MIDINoteMessage){
            return nil
        }

        let data = UnsafePointer<MIDINoteMessage>(event!.data)
        return data.memory
    }
    
}
