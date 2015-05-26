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
    @IBOutlet var stpTrack: UIStepper!
    @IBOutlet var stpTranspose: UIStepper!
    @IBOutlet var lblTrack: UITextField!
    @IBOutlet var lblTranspose: UITextField!
    
    
    @IBAction func updateTrack(sender: AnyObject) {
        lblTrack.text = String(UInt32(stpTrack.value))
    }
    
    @IBAction func updateTranspose(sender: AnyObject) {
        lblTranspose.text = String(Int8(stpTranspose.value))
    }
    
    //TODO have sequence reference the new transposition
    @IBAction func transposeSequence(sender: AnyObject) {
        // get the sequence
        if let sequence = sequence {
            
            // transpose track
            TransposeTrack(sequence, UInt32(stpTrack.value), Int8(stpTranspose.value))
            
            // print transposed track
            CAShow(UnsafeMutablePointer<MusicTrack>(SequenceGetTrackByIndex(sequence, UInt32(stpTrack.value))!))
        }
    }
    
    @IBAction func resetSequence(sender: AnyObject) {
        // get the player
        if let player = player {
            
            // stop the player if started
            if PlayerIsPlaying(player) {
                PlayerStop(player)
                btnPlaySequence.setTitle("Play", forState: UIControlState.Normal)
            }
            
            // reset the player
            PlayerResetTime(player)
            println("RESET")
        }
    }
    
    @IBAction func playSequence(sender: AnyObject) {
        // get the player
        if let player = player {
            
            if btnPlaySequence.titleLabel!.text! == "Play" {
                
                // start the player
                if PlayerStart(player) {
                    btnPlaySequence.setTitle("Pause", forState: UIControlState.Normal)
                    println("PLAY")
                }
            } else {
                
                // pause the player
                if PlayerStop(player) {
                    btnPlaySequence.setTitle("Play", forState: UIControlState.Normal)
                    println("PAUSE")
                }
            }
        }
    }
    
    // on load, set up sequence, graph, and player
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        sequence = SequenceLoadFromFile(fileURL)
        
        if let sequence = sequence {
            testGraph = MusicGraph(sequence: sequence)
            testGraph!.start()
//            graph = NewMIDIGraph("GeneralUser GS MuseScore v1.442", sequence)
            player = NewPlayerWithSequence(sequence)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

