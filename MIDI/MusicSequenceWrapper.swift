//
//  MusicSequenceWrapper.swift
//  MIDI
//
//  Created by Student on 3/1/15.
//
//

import AudioToolbox

class MusicSequenceWrapper {
    
    var sequence: MusicSequence = nil
    var url: NSURL?
    
    init(sequence: MusicSequence) {
        setSequence(sequence)
    }
    
    init?(url: NSURL?) {
        var seq = MusicSequenceWrapper.loadFromFile(url)
        if seq == nil {
            return nil
        }
        setSequence(seq!)
    }
    
    init() {
        setSequence(MusicSequenceWrapper.newSequence()!)
    }
    
    class func newSequence() -> MusicSequence? {
        var sequence = MusicSequence()
        var status = NewMusicSequence(&sequence)
        
        if status != noErr {
            println("Failed to create new sequence")
            return nil
        }
        
        return sequence
    }
    
    class func loadFromFile(url: NSURL?) -> MusicSequence? {
        let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
        let flags = MusicSequenceLoadFlags(kMusicSequenceLoadSMF_ChannelsToTracks)
        
        var sequence = MusicSequence()
        var status = NewMusicSequence(&sequence)
        
        if status != noErr {
            println("Cannot create new sequence. Stopping file load.")
            return nil
        }
        
        status = MusicSequenceFileLoad(sequence, url, typeId, flags)
        
        if status != noErr {
            println("Failed to load from file")
            return nil
        }
        
        return sequence
    }
    
    class func saveToFile(sequence: MusicSequence, url: NSURL?) -> Bool {
        let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
        let flags = MusicSequenceLoadFlags(kMusicSequenceFileFlags_EraseFile)
        
        var status = MusicSequenceFileCreate(sequence, url, typeId, flags, 0)
        
        if status != noErr {
            println("Failed to save to file.")
            return false
        }
        
        return true
    }
    
    func loadFromFile() -> MusicSequence? {
        if url == nil {
            println("Please set a URL before loading")
            return nil
        }
        return loadFromFile(url)
    }
    
    func loadFromFile(url: NSURL?) -> MusicSequence? {
        return MusicSequenceWrapper.loadFromFile(url)
    }
    
    func saveToFile() -> Bool{
        if url == nil {
            println("Please set a URL before saving")
            return false
        }
        return saveToFile(url)
    }
    
    func saveToFile(url: NSURL?) -> Bool {
        return MusicSequenceWrapper.saveToFile(sequence, url: url)
    }
    
    func setURL(url: NSURL?) {
        self.url = url
    }
    
    func setSequence(sequence: MusicSequence) -> Void {
        self.sequence = sequence
    }
    
    func getSequence() -> MusicSequence {
        return sequence
    }
    
    func getTrackCount() -> UInt32? {
        var trackCount: UInt32 = 0
        var status = MusicSequenceGetTrackCount(sequence, &trackCount)
        
        if status != noErr {
            println("Error in getting track count")
            return nil
        }
        
        return trackCount
    }
    
    // clone track at index i
}
