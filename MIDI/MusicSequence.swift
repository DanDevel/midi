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

func LoadSequenceFromFile(url: NSURL?) -> MusicSequence? {
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

func SaveSequenceToFile(sequence: MusicSequence, url: NSURL?) -> Bool {
    let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
    let flags = MusicSequenceLoadFlags(kMusicSequenceFileFlags_EraseFile)
    
    let status = MusicSequenceFileCreate(sequence, url, typeId, flags, 0)
    
    if status != noErr {
        println("Failed to save to file.")
        return false
    }
    
    return true
}

func GetSequenceTrackCount(sequence: MusicSequence) -> UInt32? {
    var trackCount: UInt32 = 0
    let status = MusicSequenceGetTrackCount(sequence, &trackCount)
    
    if status != noErr {
        println("Error in getting track count")
        return nil
    }
    
    return trackCount
}

func GetSequenceTrackByIndex(sequence: MusicSequence, index: UInt32) -> MusicTrack? {
    var track = MusicTrack()
    let status = MusicSequenceGetIndTrack(sequence, index, &track)
    
    if status != noErr {
        println("Could not get track at index \(index)")
        return nil
    }
    
    return track
}

func CloneSequence(sequence: MusicSequence) -> MusicSequence? {
    var clonedSequence = NewSequence()
    
    if let clonedSequence = clonedSequence {
        // TODO
    }
    
    return nil
}
