//
//  MusicTrack.swift
//  MIDI
//
//  Created by Student on 3/5/15.
//
//


import AudioToolbox

func TrackGetLength(track: MusicTrack) -> MusicTimeStamp? {
    let property = TrackGetProperty(track, kSequenceTrackProperty_TrackLength)
    
    if let property = property {
        let data = UnsafeMutablePointer<UInt32>(property)
        return MusicTimeStamp(data.memory)
    }
    
    return nil
}

func TrackGetProperty(track: MusicTrack, propertyID: Int) -> UnsafeMutablePointer<Void>? {
    var data = UnsafeMutablePointer<Void>()
    var length = UnsafeMutablePointer<UInt32>()
    
    let status = MusicTrackGetProperty(track, UInt32(propertyID), data, length)
    
    if status != noErr {
        println("Could not get property")
        return nil
    }
    
    return data
}

func TrackJoin(track: MusicTrack, tracksToJoin: MusicTrack...) -> MusicTrack? {
    // TODO
    return nil
}
