//
//  MusicTrack.swift
//  MIDI
//
//  Created by Student on 3/5/15.
//
//


import AudioToolbox

func TrackSetDestNode(track: MusicTrack, node: AUNode) -> Bool {
    ENTRY_LOG()
    let status = MusicTrackSetDestNode(track, node)
    if status != noErr {
        log.error("could not set dest node")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func TrackGetLength(track: MusicTrack) -> MusicTimeStamp? {
    ENTRY_LOG()
    var propertyID = UInt32(kSequenceTrackProperty_TrackLength)
    var trackLength: MusicTimeStamp = -1
    var size: UInt32 = 0
   
    let status = MusicTrackGetProperty(track, propertyID, &trackLength, &size)
    
    if status != noErr {
        log.error("Could not get property")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return trackLength
}

// TODO dispose of sequence?
func TrackClone(track: MusicTrack) -> MusicTrack? {
    ENTRY_LOG()
    let sequence = NewSequence()
    if let sequence = sequence {
        var clonedTrack = SequenceNewTrack(sequence)
        if let clonedTrack = clonedTrack {
            let result = TrackMergeAll(track, clonedTrack)
            if result {
                EXIT_LOG()
                return clonedTrack
            }
        }
    }
    EXIT_LOG()
    return nil
}

func TrackMerge(track: MusicTrack, destTrack: MusicTrack, destOffset: Float64) -> Bool {
    ENTRY_LOG()
    let trackLength = TrackGetLength(track)
    if let trackLength = trackLength {
        let status = MusicTrackMerge(track, 0, trackLength, destTrack, destOffset)
        if status != noErr {
            log.error("Could not add track to sequence")
            EXIT_LOG()
            return false
        }
        EXIT_LOG()
        return true
    } else {
        EXIT_LOG()
        return false
    }
}

func TrackMergeAll(track: MusicTrack, destTrack: MusicTrack) -> Bool {
    ENTRY_LOG()
    return TrackMerge(track, destTrack, 0)
}

func TrackJoin(track1: MusicTrack, track2: MusicTrack) -> Bool {
    ENTRY_LOG()
    let offset = TrackGetLength(track1)
    if let offset = offset {
        EXIT_LOG()
        return TrackMerge(track2, track1, offset)
    }
    EXIT_LOG()
    return false
}


// TODO figure out better lambda
func TrackIsDrum(track: MusicTrack) -> Bool {
    ENTRY_LOG()
    var found = false
    func helper(e: IteratorEvent) {
        if !found && EventIsNote(e) {
            if EventToNote(e)!.channel == 9 { // make this a constant
                found = true   // stop the iterator even if false for optimization
            }
        }
    }
    var iterator = NewIterator(track)
    if let iterator = iterator {
        IteratorFor(iterator, helper)
    }
    EXIT_LOG()
    return found
}
