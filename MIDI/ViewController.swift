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
    
    @IBAction func transposeSequence(sender: AnyObject) {
        if let sequence = sequence {
            // transpose track
            let transposedTrack = TransposeTrack(sequence, UInt32(stpTrack.value), Int8(stpTranspose.value))
            // print transposed track
            CAShow(UnsafeMutablePointer<MusicTrack>(transposedTrack!))
        }
    }
    
    @IBAction func playSequence(sender: AnyObject) {
        // get the graph
        if let graph = graph {
            
            // start the graph
            if GraphStart(graph) {
                
                // get the player
                if let player = player {
                    
                    // start the player
                    if PlayerPlayFromBeginning(player) {
                        
                        // get the sequence
                        if let sequence = sequence {
                            
                            println("Player started.")
                            CAShow(UnsafeMutablePointer<AUGraph>(graph))
                            //CAShow(UnsafeMutablePointer<MusicSequence>(sequence))
                            
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = NSBundle.mainBundle().URLForResource("simpletest", withExtension: "mid")
        sequence = SequenceLoadFromFile(fileURL)
        
        if let sequence = sequence {
            graph = NewMIDIGraph("Gorts_Filters", sequence)
            player = NewPlayerWithSequence(sequence)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

