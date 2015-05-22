//
//  MusicSequence.swift
//  MIDI
//
//  Created by Student on 3/1/15.
//
//

import AudioToolbox


func NewSequence() -> MusicSequence? {
    var sequence = MusicSequence()
    let status = NewMusicSequence(&sequence)
    
    if status != noErr {
        println("Failed to create new sequence")
        return nil
    }
    
    return sequence
}

func SequenceDispose(sequence: MusicSequence) -> Bool {
    let status = DisposeMusicSequence(sequence)
    
    if status != noErr {
        println("Failed to dispose of sequence")
        return false
    }
    
    return true
}

func SequenceLoadFromFile(url: NSURL?) -> MusicSequence? {
    let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
    let flags = MusicSequenceLoadFlags(kMusicSequenceLoadSMF_ChannelsToTracks)
    
    let sequence = NewSequence()
    
    if let sequence = sequence {
        let status = MusicSequenceFileLoad(sequence, url, typeId, flags)
        
        if status != noErr {
            println("Failed to load from file")
            return nil
        }
        
        return sequence
    }
    
    return nil
}

func SequenceSaveToFile(sequence: MusicSequence, url: NSURL?) -> Bool {
    let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
    let flags = MusicSequenceLoadFlags(kMusicSequenceFileFlags_EraseFile)
    
    let status = MusicSequenceFileCreate(sequence, url, typeId, flags, 0)
    
    if status != noErr {
        println("Failed to save to file.")
        return false
    }
    
    return true
}

func SequenceGetLastTrack(sequence: MusicSequence) -> MusicTrack? {
    return SequenceGetTrackByIndex(sequence, SequenceGetTrackCount(sequence)! - 1)
}

func SequenceGetTrackCount(sequence: MusicSequence) -> UInt32? {
    var trackCount: UInt32 = 0
    let status = MusicSequenceGetTrackCount(sequence, &trackCount)
    
    if status != noErr {
        println("Error in getting track count")
        return nil
    }
    
    return trackCount
}

func SequenceNewTrack(sequence: MusicSequence) -> MusicTrack? {
    var track = MusicTrack()
    var status = MusicSequenceNewTrack(sequence, &track)
    
    if status != noErr {
        println("Could not add track to sequence")
        return nil
    }
    
    return track
}

func SequenceAddTrack(sequence: MusicSequence, track: MusicTrack) -> Bool {
    var newTrack = SequenceNewTrack(sequence)
    if let newTrack = newTrack {
        return TrackMergeAll(track, newTrack)
    }
    return false
}

func SequenceGetTrackByIndex(sequence: MusicSequence, index: UInt32) -> MusicTrack? {
    var track = MusicTrack()
    let status = MusicSequenceGetIndTrack(sequence, index, &track)
    
    if status != noErr {
        println("Could not get track at index \(index)")
        return nil
    }
    
    return track
}

func SequenceClone(sequence: MusicSequence) -> MusicSequence? {
    var clonedSequence = NewSequence()
    
    if let clonedSequence = clonedSequence {
        let numOfTracks = SequenceGetTrackCount(sequence)
        if let numOfTracks = numOfTracks {
            for index in 0..<numOfTracks {
                var track = SequenceGetTrackByIndex(sequence, index)
                if let track = track {
                    SequenceAddTrack(clonedSequence, track)
                }
            }
            return clonedSequence
        }
    }
    
    return nil
}

func SequenceSetAUGraph(sequence: MusicSequence, graph: AUGraph) -> Bool {
    let status = MusicSequenceSetAUGraph(sequence, graph)
    if status != noErr {
        println("Could not set au graph")
        return false
    }
    return true
}
