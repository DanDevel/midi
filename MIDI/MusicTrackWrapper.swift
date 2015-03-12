//
//  MusicTrackWrapper.swift
//  MIDI
//
//  Created by Student on 3/5/15.
//
//



// is this class needed?????

import AudioToolbox

class MusicTrackWrapper {
    
    var track: MusicTrack = nil
    var sequence: MusicSequenceWrapper
    
    init(track: MusicTrack, sequence: MusicSequenceWrapper) {
        self.track = track
        self.sequence = sequence
    }
    
    func setTrack(track: MusicTrack) -> Void {
        self.track = track
    }
    
    func getTrack() -> MusicTrack {
        return track
    }
    
    func getProperty(propID: Int) -> UnsafeMutablePointer<Void>? {
        var data = UnsafeMutablePointer<Void>()
        var length = UnsafeMutablePointer<UInt32>()
        
        var status = MusicTrackGetProperty(track, UInt32(propID), data, length)
        
        if status != noErr {
            println("Could not get property")
            return nil
        }
        
        return data
    }
    
    // make this static?
    func getLength() -> MusicTimeStamp {
        var prop = getProperty(kSequenceTrackProperty_TrackLength)
        var data = UnsafeMutablePointer<UInt32>(prop!)
        return MusicTimeStamp(data.memory)
    }
    
    //make static merge method

}
