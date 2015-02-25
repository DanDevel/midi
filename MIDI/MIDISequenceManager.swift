//
//  MIDISequenceManager.swift
//  MIDI
//
//  Created by Student on 2/25/15.
//
//

import AudioToolbox

class MIDISequenceManager {
    
    class func loadSequenceFromFile(filename: String) -> MusicSequence {
        
        let filenameArr = filename.componentsSeparatedByString(".")
        let name = filenameArr[0]
        let ext = filenameArr[1]
        
        let fileURL = NSBundle.mainBundle().URLForResource(name, withExtension: ext)
        let typeId = MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType)
        let flags = MusicSequenceLoadFlags(kMusicSequenceLoadSMF_ChannelsToTracks)
        
        var sequence = MusicSequence()
        var status = MusicSequenceFileLoad(sequence, fileURL, typeId, flags)
        
        return sequence
    }
    
}