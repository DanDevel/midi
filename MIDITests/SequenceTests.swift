//
//  SequenceTests.swift
//  MIDI
//
//  Created by Student on 6/2/15.
//
//

import XCTest
import AudioToolbox

class SequenceTests: XCTestCase {
    
    var url: NSURL?
    var sequence: MusicSequence?
    
    override func setUp() {
        super.setUp()
        url = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        sequence = SequenceLoadFromFile(url!)
    }
    
    func testNewSequence() {
        if let sequence = NewSequence() {}
        else {
            XCTFail("sequence should not be nil")
        }
    }
    
    func testSequenceFromFile() {
        if let sequence = sequence {}
        else {
            XCTFail("sequence should not be nil")
        }
    }
    
}