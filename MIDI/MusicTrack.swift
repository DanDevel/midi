//
//  MusicTrack.swift
//  MIDI
//
//  Created by Student on 3/5/15.
//
//


import AudioToolbox

func TrackGetLength(track: MusicTrack) -> MusicTimeStamp? {
    var propertyID = UInt32(kSequenceTrackProperty_TrackLength)
    var trackLength: MusicTimeStamp = -1
    var size: UInt32 = 0
   
    let status = MusicTrackGetProperty(track, propertyID, &trackLength, &size)
    
    if status != noErr {
        println("Could not get property")
        return nil
    }

    return trackLength
}

func TrackClone(track: MusicTrack) -> MusicTrack? {
    let sequence = NewSequence()
    if let sequence = sequence {
        var clonedTrack = SequenceNewTrack(sequence)
        if let clonedTrack = clonedTrack {
            let result = TrackMergeAll(track, clonedTrack)
            if result {
                return clonedTrack
            }
        }
    }
    return nil
}

func TrackMerge(track: MusicTrack, destTrack: MusicTrack, destOffset: Float64) -> Bool {
    let trackLength = TrackGetLength(track)
    if let trackLength = trackLength {
        let status = MusicTrackMerge(track, 0, trackLength, destTrack, destOffset)
        if status != noErr {
            println("Could not add track to sequence")
            return false
        }
        return true
    } else {
        return false
    }
}

func TrackMergeAll(track: MusicTrack, destTrack: MusicTrack) -> Bool {
    return TrackMerge(track, destTrack, 0)
}

func TrackJoin(track1: MusicTrack, track2: MusicTrack) -> Bool {
    let offset = TrackGetLength(track1)
    if let offset = offset {
        return TrackMerge(track2, track1, offset)
    }
    return false
}
