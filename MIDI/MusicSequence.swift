//
//  MusicSequence.swift
//  MIDI
//
//  Created by Student on 3/1/15.
//
//

import AudioToolbox


func NewSequence() -> MusicSequence? {
    ENTRY_LOG()
    var sequence = MusicSequence()
    let status = NewMusicSequence(&sequence)
    
    if status != noErr {
        log.error("Failed to create new sequence")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return sequence
}

func SequenceDispose(sequence: MusicSequence) -> Bool {
    ENTRY_LOG()
    let status = DisposeMusicSequence(sequence)
    
    if status != noErr {
        log.error("Failed to dispose of sequence")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func SequenceLoadFromFile(url: NSURL?) -> MusicSequence? {
    ENTRY_LOG()
    let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
    let flags = MusicSequenceLoadFlags(kMusicSequenceLoadSMF_ChannelsToTracks)
    
    let sequence = NewSequence()
    
    if let sequence = sequence {
        let status = MusicSequenceFileLoad(sequence, url, typeId, flags)
        
        if status != noErr {
            log.error("Failed to load from file")
            EXIT_LOG()
            return nil
        }
        EXIT_LOG()
        return sequence
    }
    EXIT_LOG()
    return nil
}

func SequenceSaveToFile(sequence: MusicSequence, url: NSURL?) -> Bool {
    ENTRY_LOG()
    let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
    let flags = MusicSequenceLoadFlags(kMusicSequenceFileFlags_EraseFile)
    
    let status = MusicSequenceFileCreate(sequence, url, typeId, flags, 0)
    
    if status != noErr {
        log.error("Failed to save to file.")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}

func SequenceGetLastTrack(sequence: MusicSequence) -> MusicTrack? {
    ENTRY_LOG()
    return SequenceGetTrackByIndex(sequence, SequenceGetTrackCount(sequence)! - 1)
}

func SequenceGetTrackCount(sequence: MusicSequence) -> UInt32? {
    ENTRY_LOG()
    var trackCount: UInt32 = 0
    let status = MusicSequenceGetTrackCount(sequence, &trackCount)
    
    if status != noErr {
        log.error("Error in getting track count")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return trackCount
}

func SequenceNewTrack(sequence: MusicSequence) -> MusicTrack? {
    ENTRY_LOG()
    var track = MusicTrack()
    var status = MusicSequenceNewTrack(sequence, &track)
    
    if status != noErr {
        log.error("Could not add track to sequence")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return track
}

func SequenceAddTrack(sequence: MusicSequence, track: MusicTrack) -> Bool {
    ENTRY_LOG()
    var newTrack = SequenceNewTrack(sequence)
    if let newTrack = newTrack {
        EXIT_LOG()
        return TrackMergeAll(track, newTrack)
    }
    EXIT_LOG()
    return false
}

func SequenceGetTrackByIndex(sequence: MusicSequence, index: UInt32) -> MusicTrack? {
    ENTRY_LOG()
    var track = MusicTrack()
    let status = MusicSequenceGetIndTrack(sequence, index, &track)
    
    if status != noErr {
        log.error("Could not get track at index \(index)")
        EXIT_LOG()
        return nil
    }
    EXIT_LOG()
    return track
}

func SequenceClone(sequence: MusicSequence) -> MusicSequence? {
    ENTRY_LOG()
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
            EXIT_LOG()
            return clonedSequence
        }
    }
    EXIT_LOG()
    return nil
}

func SequenceSetAUGraph(sequence: MusicSequence, graph: AUGraph) -> Bool {
    ENTRY_LOG()
    let status = MusicSequenceSetAUGraph(sequence, graph)
    if status != noErr {
        log.error("Could not set au graph")
        EXIT_LOG()
        return false
    }
    EXIT_LOG()
    return true
}
