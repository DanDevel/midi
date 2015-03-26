//
//  MusicEventIterator.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox


func NewIterator(track: MusicTrack) -> MusicEventIterator? {
    var iterator = MusicEventIterator()
    let status = NewMusicEventIterator(track, &iterator)
    
    if status != noErr {
        println("Failed to create new iterator")
        return nil
    }
    
    return iterator
}

func IteratorHasNextEvent(iterator: MusicEventIterator) -> Bool {
    var hasNext = Boolean()
    let status = MusicEventIteratorHasNextEvent(iterator, &hasNext)
    
    if status != noErr {
        println("Could not check for next event.")
        return false
    }
    
    return hasNext != 0
}

func IteratorHasCurrentEvent(iterator: MusicEventIterator) -> Bool {
    var hasCurrent = Boolean()
    let status = MusicEventIteratorHasCurrentEvent(iterator, &hasCurrent)
    
    if status != noErr {
        println("Could not check for next event.")
        return false
    }
    
    return hasCurrent != 0
}

func IteratorToNextEvent(iterator: MusicEventIterator) -> Bool {
    if !IteratorHasNextEvent(iterator) {
        return false
    }
    
    let status = MusicEventIteratorNextEvent(iterator)
    
    if status != noErr {
        println("Failed to get Next Event")
        return false
    }
    
    return true
}

struct IteratorEvent {
    var timeStamp: MusicTimeStamp
    var type: MusicEventType
    var data: UnsafePointer<()>
    var dataSize: UInt32
}

func IteratorGetCurrentNoteEvent(iterator: MusicEventIterator) -> MIDINoteMessage? {
    let event = IteratorGetCurrentEvent(iterator)
    
    if let event = event {
        if event.type != MusicEventType(kMusicEventType_MIDINoteMessage) {
            println("Event isn't midi")
            return nil
        }
        
        let data = UnsafePointer<MIDINoteMessage>(event.data)
        return data.memory
    }
    
    return nil
}

func IteratorSetCurrentNoteEvent(iterator: MusicEventIterator, noteMessage: MIDINoteMessage) -> Bool {
    var message: MIDINoteMessage = noteMessage
    let type = MusicEventType(kMusicEventType_MIDINoteMessage)
    return IteratorSetCurrentEvent(iterator, IteratorEvent(timeStamp: -1, type: type, data: &message, dataSize: 0))
}

private func IteratorGetCurrentEvent(iterator: MusicEventIterator) -> IteratorEvent? {
    var timeStamp = MusicTimeStamp()
    var type = MusicEventType()
    var data: UnsafePointer<()> = nil
    var dataSize = UInt32()
    
    let status = MusicEventIteratorGetEventInfo(iterator, &timeStamp, &type, &data, &dataSize)
    
    if status != noErr {
        return nil
    }
    
    return IteratorEvent(timeStamp: timeStamp, type: type, data: data, dataSize: dataSize)
}

private func IteratorSetCurrentEvent(iterator: MusicEventIterator, event: IteratorEvent) -> Bool {
    let status = MusicEventIteratorSetEventInfo(iterator, event.type, event.data)
    
    if status != noErr {
        println("Could not set event info")
        return false
    }
    
    return true
}


