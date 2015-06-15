//
//  MIDITests.swift
//  MIDITests
//
//  Created by Student on 2/25/15.
//
//

import XCTest
import AudioToolbox

class MIDITests: XCTestCase {
    
    var sequence: MusicSequence?
    var iterator: MusicEventIterator?
    var event: IteratorEvent?
    
    override func setUp() {
        super.setUp()
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        sequence = SequenceLoadFromFile(fileURL)
        let track1 = SequenceGetTrackByIndex(sequence!, 1)!
        iterator = NewIterator(track1)
        event = IteratorGetCurrentEvent(iterator!)
    }
    
    func testEventToNote() {
        XCTAssert(EventToNote(event!)!.note == EventToNote(event!)!.note, "Notes should be equal")
        XCTAssert(EventToNote(event!)!.note == EventToNote(NoteToEvent(EventToNote(event!)!))!.note, "conversions mess stuff up..")
    }
    
}
