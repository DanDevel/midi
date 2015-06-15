//
//  MusicEventIterator.swift
//  MIDI
//
//  Created by Student on 3/4/15.
//
//

import AudioToolbox


func NewIterator(track: MusicTrack) -> MusicEventIterator? {
    ENTRY_LOG()
    var iterator = MusicEventIterator()
    let status = NewMusicEventIterator(track, &iterator)
    
    if status != noErr {
        log.error("Failed to create new iterator")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return iterator
}

func IteratorHasNextEvent(iterator: MusicEventIterator) -> Bool {
    ENTRY_LOG()
    var hasNext = Boolean()
    let status = MusicEventIteratorHasNextEvent(iterator, &hasNext)
    
    if status != noErr {
        log.error("Could not check for next event.")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return hasNext != 0
}

func IteratorHasCurrentEvent(iterator: MusicEventIterator) -> Bool {
    ENTRY_LOG()
    var hasCurrent = Boolean()
    let status = MusicEventIteratorHasCurrentEvent(iterator, &hasCurrent)
    
    if status != noErr {
        log.error("Could not check for next event.")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return hasCurrent != 0
}

func IteratorToNextEvent(iterator: MusicEventIterator) -> Bool {
    ENTRY_LOG()
    if !IteratorHasNextEvent(iterator) {
        EXIT_LOG()
        return false
    }
    
    let status = MusicEventIteratorNextEvent(iterator)
    
    if status != noErr {
        log.error("Failed to get Next Event")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func IteratorReset(iterator: MusicEventIterator) {
    ENTRY_LOG()
    let status = MusicEventIteratorSeek(iterator, MusicTimeStamp(0))
    if status != noErr {
        log.error("Failed to Reset Iterator")
    }
    EXIT_LOG()
}

struct IteratorEvent {
    var timeStamp: MusicTimeStamp
    var type: MusicEventType
    var data: UnsafePointer<()>
    var dataSize: UInt32
}

// DEPRECATE THIS
func IteratorGetCurrentNoteEvent(iterator: MusicEventIterator) -> MIDINoteMessage? {
    ENTRY_LOG()
    let event = IteratorGetCurrentEvent(iterator)
    
    if let event = event {
        if event.type != MusicEventType(kMusicEventType_MIDINoteMessage) {
            log.error("Event isn't midi")
            EXIT_LOG()
            return nil
        }
        
        let data = UnsafePointer<MIDINoteMessage>(event.data)
        EXIT_LOG()
        return data.memory
    }
    EXIT_LOG()
    return nil
}

func EventIsNote(event: IteratorEvent) -> Bool {
    ENTRY_LOG()
    EXIT_LOG()
    return event.type == MusicEventType(kMusicEventType_MIDINoteMessage)
}

func EventIsMeta(event: IteratorEvent) -> Bool {
    ENTRY_LOG()
    EXIT_LOG()
    return event.type == MusicEventType(kMusicEventType_Meta)
}

func EventToNote(event: IteratorEvent) -> MIDINoteMessage? {
    ENTRY_LOG()
    if !EventIsNote(event) {
        return nil
    }
    let data = UnsafePointer<MIDINoteMessage>(event.data)
    EXIT_LOG()
    return data.memory
}

func EventToMeta(event: IteratorEvent) -> MIDIMetaEvent? {
    ENTRY_LOG()
    if !EventIsMeta(event) {
        return nil
    }
    let data = UnsafePointer<MIDIMetaEvent>(event.data)
    EXIT_LOG()
    return data.memory
}

var n_:MIDINoteMessage = MIDINoteMessage() // ugly hack to make the pointers work.
func NoteToEvent(note: MIDINoteMessage) -> IteratorEvent {
    ENTRY_LOG()
    n_ = note
    EXIT_LOG()
    return IteratorEvent(timeStamp: -1, // unused
                         type: MusicEventType(kMusicEventType_MIDINoteMessage),
                         data: &n_,
                         dataSize: 0)   // unused
}

var m_: MIDIMetaEvent = MIDIMetaEvent() // ugly hack to make pointers work.
func MetaToEvent(meta: MIDIMetaEvent) -> IteratorEvent {
    ENTRY_LOG()
    m_ = meta
    EXIT_LOG()
    return IteratorEvent(timeStamp: -1,
        type: MusicEventType(kMusicEventType_Meta),
        data: &m_,
        dataSize: 0)
}

//func IteratorGetCurrentMetaEvent(iterator: MusicEventIterator) -> MIDIMetaEvent? {
//    let event = IteratorGetCurrentEvent(iterator)
//    
//    if let event = event {
//        if event.type != MusicEventType(kMusicEventType_Meta) {
//            log.error("Event isn't meta")
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
    ENTRY_LOG()
    var message: MIDINoteMessage = noteMessage
    let type = MusicEventType(kMusicEventType_MIDINoteMessage)
    let result = IteratorSetCurrentEvent(iterator, IteratorEvent(timeStamp: -1, type: type, data: &message, dataSize: 0))
    EXIT_LOG()
    return result
}

func IteratorGetCurrentEvent(iterator: MusicEventIterator) -> IteratorEvent? {
    ENTRY_LOG()
    var timeStamp = MusicTimeStamp()
    var type = MusicEventType()
    var data: UnsafePointer<()> = nil
    var dataSize = UInt32()
    
    let status = MusicEventIteratorGetEventInfo(iterator, &timeStamp, &type, &data, &dataSize)
    
    if status != noErr {
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return IteratorEvent(timeStamp: timeStamp, type: type, data: data, dataSize: dataSize)
}

func IteratorSetCurrentEvent(iterator: MusicEventIterator, event: IteratorEvent) -> Bool {
    ENTRY_LOG()
    let status = MusicEventIteratorSetEventInfo(iterator, event.type, event.data)
    
    if status != noErr {
        log.error("Could not set event info")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func IteratorGetEvents(iterator: MusicEventIterator) -> Array<IteratorEvent> {
    ENTRY_LOG()
    var result = Array<IteratorEvent>()
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    while hasCurrentEvent {
        result.append(IteratorGetCurrentEvent(iterator)!)
        hasCurrentEvent = IteratorToNextEvent(iterator)
    }
    EXIT_LOG()
    return result
}

// Assumption: events is equal to number of events in iterator
func IteratorSetEvents(iterator: MusicEventIterator, events: Array<IteratorEvent>) {
    ENTRY_LOG()
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    var i = 0
    while hasCurrentEvent {
        IteratorSetCurrentEvent(iterator, events[i])
        hasCurrentEvent = IteratorToNextEvent(iterator)
        i++
    }
    EXIT_LOG()
}

func IteratorMap(iterator: MusicEventIterator, f: IteratorEvent -> IteratorEvent) {
    ENTRY_LOG()
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    while hasCurrentEvent {
        let event = IteratorGetCurrentEvent(iterator)!
        var succuess = IteratorSetCurrentEvent(iterator, f(event))
        hasCurrentEvent = IteratorToNextEvent(iterator)
    }
    EXIT_LOG()
}

func IteratorFor(iterator: MusicEventIterator, f: IteratorEvent -> ()) {
    ENTRY_LOG()
    IteratorReset(iterator)
    var hasCurrentEvent = IteratorHasCurrentEvent(iterator)
    while hasCurrentEvent {
        let event = IteratorGetCurrentEvent(iterator)!
        f(event)
        hasCurrentEvent = IteratorToNextEvent(iterator)
    }
    EXIT_LOG()
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
    ENTRY_LOG()
    var result = Array<MIDIMetaEvent>()
    var events = IteratorGetEvents(iterator)
    for e in events {
        if EventIsMeta(e) {
            let data = UnsafePointer<MIDIMetaEvent>(e.data)
            result.append(data.memory)
        }
    }
    EXIT_LOG()
    return result
}

//MusicSequenceGetT

// TODO
func MetaEventGetContent(event: MIDIMetaEvent) -> String {
    ENTRY_LOG()
//    event.data.value
//    event.data
//    NSData(bytes: raw, length: event.dataLength)
//    var data = NSData(bytes: event.data.value, length: event.dataLength.value)
//    return NSString(data: data, encoding: NSUTF8StringEncoding)
    log.debug("\(event.data)")
    log.debug("\(event.dataLength)")
    log.debug("\(event.metaEventType)")
    log.debug("---")
    EXIT_LOG()
    return "Bass"
}


// TODO ?
func EventPrint(event: IteratorEvent) -> () {
    ENTRY_LOG()
    switch (event.type) {
    case MusicEventType(kMusicEventType_MIDINoteMessage):
        let e = EventToNote(event)!
        log.debug("Note Event: \(e.note)")
        break
    case MusicEventType(kMusicEventType_Meta):
        let e = EventToMeta(event)!
        //log.debug("Meta Event: \(e.)"
    default: break
    }
    EXIT_LOG()
}



// TODO focus on getting correct presets
// TODO look at other events besides NOTE
