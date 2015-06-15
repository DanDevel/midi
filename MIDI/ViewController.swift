//
//  ViewController.swift
//  MIDI
//
//  Created by Student on 2/25/15.
//
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    var sequence: MusicSequence?
    var graph: AUGraph?
    var player: MusicPlayer?
    
    // TODO
    var testGraph: MusicGraph?
    
    
    @IBOutlet var btnResetSequence: UIButton!
    @IBOutlet var btnTransposeSequence: UIButton!
    @IBOutlet var btnPlaySequence: UIButton!
    @IBOutlet var btnTrackInfo: UIButton!
    
    @IBOutlet var stpTrack: UIStepper!
    @IBOutlet var stpTranspose: UIStepper!
    
    @IBOutlet var lblTrack: UITextField!
    @IBOutlet var lblTranspose: UITextField!
    
    
    @IBAction func printTrackInfo(sender: AnyObject) {
        ENTRY_LOG()
//        var iterator = NewIterator(SequenceGetTrackByIndex(sequence!, UInt32(stpTrack.value))!)!
//        IteratorFor(iterator, EventPrint)
        
        var track = SequenceGetTrackByIndex(sequence!, UInt32(stpTrack.value))!
        CAShow(UnsafeMutablePointer<MusicTrack>(track))
        EXIT_LOG()
    }
    
    @IBAction func updateTrack(sender: AnyObject) {
        ENTRY_LOG()
        lblTrack.text = String(UInt32(stpTrack.value))
        EXIT_LOG()
    }
    
    @IBAction func updateTranspose(sender: AnyObject) {
        ENTRY_LOG()
        lblTranspose.text = String(Int8(stpTranspose.value))
        EXIT_LOG()
    }
    
    //TODO have sequence reference the new transposition
    @IBAction func transposeSequence(sender: AnyObject) {
        ENTRY_LOG()
        // get the sequence
        if let sequence = sequence {
            
            // transpose track
            TransposeTrack(sequence, UInt32(stpTrack.value), Int8(stpTranspose.value))
            
            // print transposed track
            CAShow(UnsafeMutablePointer<MusicTrack>(SequenceGetTrackByIndex(sequence, UInt32(stpTrack.value))!))
        }
        EXIT_LOG()
    }
    
    @IBAction func resetSequence(sender: AnyObject) {
        ENTRY_LOG()
        // get the player
        if let player = player {
            
            // stop the player if started
            if PlayerIsPlaying(player) {
                PlayerStop(player)
                btnPlaySequence.setTitle("Play", forState: UIControlState.Normal)
            }
            
            // reset the player
            PlayerResetTime(player)
            log.info("Player Reset")
        }
        EXIT_LOG()
    }
    
    @IBAction func playSequence(sender: AnyObject) {
        ENTRY_LOG()
        // get the player
        if let player = player {
            
            if btnPlaySequence.titleLabel!.text! == "Play" {
                
                // start the player
                if PlayerStart(player) {
                    btnPlaySequence.setTitle("Pause", forState: UIControlState.Normal)
                    log.info("Player Playing")
                }
            } else {
                
                // pause the player
                if PlayerStop(player) {
                    btnPlaySequence.setTitle("Play", forState: UIControlState.Normal)
                    log.info("Player Paused")
                }
            }
        }
        EXIT_LOG()
    }
    
    // on load, set up sequence, graph, and player
    override func viewDidLoad() {
        ENTRY_LOG()
        super.viewDidLoad()
        
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        sequence = SequenceLoadFromFile(fileURL)
        
        if let sequence = sequence {
            testGraph = MusicGraph(sequence: sequence)
            testGraph!.start()
//            graph = NewMIDIGraph("GeneralUser GS MuseScore v1.442", sequence)
            player = NewPlayerWithSequence(sequence)
        }
        EXIT_LOG()
    }

    override func didReceiveMemoryWarning() {
        ENTRY_LOG()
        super.didReceiveMemoryWarning()
        EXIT_LOG()
    }
}

