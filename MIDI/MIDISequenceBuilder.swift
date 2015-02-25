//
//  MIDISequenceBuilder.swift
//  MIDI
//
//  Created by Student on 2/25/15.
//
//

import AudioToolbox

class MIDISequenceBuilder {
    
    var sequence: MusicSequence
    
    init() {
        sequence = MusicSequence()
        var status = NewMusicSequence(&sequence)
        // add error checking
    }
    
    init(sequence: MusicSequence) {
        self.sequence = sequence
    }
    
}
