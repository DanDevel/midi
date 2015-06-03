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

func IteratorReset(iterator: MusicEventIterator) {
    let status = MusicEventIteratorSeek(iterator, MusicTimeStamp(0))
    if status != noErr {
        println("Failed to Reset Iterator")
    }
}

struct IteratorEvent {
    var timeStamp: MusicTimeStamp
    var type: MusicEventType
    var data: UnsafePointer<()>
    var dataSize: UInt32
}

// DEPRECATE THIS
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

func EventIsNote(event: IteratorEvent) -> Bool {
    return event.type == MusicEventType(kMusicEventType_MIDINoteMessage)
}

func EventIsMeta(event: IteratorEvent) -> Bool {
    return event.type == MusicEventType(kMusicEventType_Meta)
}

func EventToNote(event: IteratorEvent) -> MIDINoteMessage? {
    if !EventIsNote(event) {
        return nil
    }
    let data = UnsafePointer<MIDINoteMessage>(event.data)
    return data.memory
}

func EventToMeta(event: IteratorEvent) -> MIDIMetaEvent? {
    if !EventIsMeta(event) {
        return nil
    }
    let data = UnsafePointer<MIDIMetaEvent>(event.data)
    return data.memory
}

var n_:MIDINoteMessage = MIDINoteMessage() // ugly hack to make the pointers work.
func NoteToEvent(note: MIDINoteMessage) -> IteratorEvent {
    n_ = note
    return IteratorEvent(timeStamp: -1, // unused
                         type: MusicEventType(kMusicEventType_MIDINoteMessage),
                         data: &n_,
                         dataSize: 0)   // unused
}

func MetaToEvent(meta: MIDIMetaEvent) -> IteratorEvent {
    var m = meta
    return IteratorEvent(timeStamp: -1,
        type: MusicEventType(kMusicEventType_Meta),
        data: &m,
        dataSize: 0)
}

//func IteratorGetCurrentMetaEvent(iterator: MusicEventIterator) -> MIDIMetaEvent? {
//    let event = IteratorGetCurrentEvent(iterator)
//    
//    if let event = event {
//        if event.type != MusicEventType(kMusicEventType_Meta) {
//            println("Event isn't meta")
//            return nil
//        }
//        let data = UnsafePointer<MIDIMetaEvent>(event.data)
//        return data.memory
//    }
//    
//    return nil
//}

// DEPRECATE THIS
func IteratorSetCurrentNoteEvent(iterator: MusicEventIterator, noteMessage: MIDINoteMessage) -> Bool {
    var message: MIDINoteMessage = noteMessage
    let type = MusicEventType(kMusicEventType_MIDINoteMessage)
    return IteratorSetCurrentEvent(iterator, IteratorEvent(timeStamp: -1, type: type, data: &message, dataSize: 0))
}

func IteratorGetCurrentEvent(iterator: MusicEventIterator) -> IteratorEvent? {
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

func IteratorSetCurrentEvent(iterator: MusicEventIterator, event: IteratorEvent) -> Bool {
    let status = MusicEventIteratorSetEventInfo(iterator, event.type, event.data)
    
    if status != noErr {
        println("Could not set event info")
        return false
    }
    
    return true
}

func IteratorGetEvents(iterator: MusicEventIterator) -> Array<IteratorEvent> {
    var result = Array<IteratorEvent>()
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    while hasCurrentEvent {
        result.append(IteratorGetCurrentEvent(iterator)!)
        hasCurrentEvent = IteratorToNextEvent(iterator)
    }
    return result
}

// Assumption: events is equal to number of events in iterator
func IteratorSetEvents(iterator: MusicEventIterator, events: Array<IteratorEvent>) {
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    var i = 0
    while hasCurrentEvent {
        IteratorSetCurrentEvent(iterator, events[i])
        hasCurrentEvent = IteratorToNextEvent(iterator)
        i++
    }
}

func IteratorMap(iterator: MusicEventIterator, f: IteratorEvent -> IteratorEvent) {
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    while hasCurrentEvent {
        let event = IteratorGetCurrentEvent(iterator)!
        
        // TODO check EventToNote function?
        if EventIsNote(event) {
//            println("Note: \(EventToNote(event)!.note)")
            let newEvent = f(event)
            println("Transposed Note: \(EventToNote(newEvent)!.note)")
            var succuess = IteratorSetCurrentEvent(iterator, newEvent)
        }
        
        
        hasCurrentEvent = IteratorToNextEvent(iterator)
    }
}

//func IteratorGetMetaEvents(iterator: MusicEventIterator) -> Array<MIDIMetaEvent> {
//    var events = Array<MIDIMetaEvent>()
//    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
//    while  hasCurrentEvent {
//        let noteEvent = IteratorGetCurrentMetaEvent(iterator)!
//        events.append(noteEvent)
//        hasCurrentEvent = IteratorToNextEvent(iterator)
//    }
//    return events
//}

func IteratorGetMetaEvents(iterator: MusicEventIterator) -> Array<MIDIMetaEvent> {
    var result = Array<MIDIMetaEvent>()
    var events = IteratorGetEvents(iterator)
    for e in events {
        if EventIsMeta(e) {
            let data = UnsafePointer<MIDIMetaEvent>(e.data)
            result.append(data.memory)
        }
    }
    return result
}

//MusicSequenceGetT

// TODO
func MetaEventGetContent(event: MIDIMetaEvent) -> String {
//    event.data.value
//    event.data
//    NSData(bytes: raw, length: event.dataLength)
//    var data = NSData(bytes: event.data.value, length: event.dataLength.value)
//    return NSString(data: data, encoding: NSUTF8StringEncoding)
    println(event.data)
    println(event.dataLength)
    println(event.metaEventType)
    println("---")
    return "Bass"
}



// TODO focus on getting correct presets
// TODO look at other events besides NOTE
