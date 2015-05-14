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

    let sequence = ViewController.loadSequence()
    
    
    
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
        if let sequence = sequence {
            
            // create new AUGraph
            var graph = NewMIDIGraph()
            if let graph = graph {
                
                // start the graph
                if GraphStart(graph) {
                    
                    // get sampler node
                    if let samplerNode = GraphGetNode(graph, 0) { // keep track of this index
                        
                        // get sampler unit
                        if let samplerUnit = GraphGetAudioUnit(graph, samplerNode) {
                            
                            // add sound font
                            if GraphAddSoundFontToAudioUnit("Gorts_Filters", samplerUnit) {
                                
                                // associate the sequence with the graph
                                if SequenceSetAUGraph(sequence, graph) {
                                    
                                    // create new music player
                                    var player = NewPlayer()
                                    if let player = player {
                                        
                                        // add the sequence to the player
                                        if PlayerSetSequence(player, sequence) {
                                            
                                            // start the player
                                            if PlayerPlayFromBeginning(player) {
                                                println("Player started.")
                                                CAShow(UnsafeMutablePointer<AUGraph>(graph))
//                                                CAShow(UnsafeMutablePointer<MusicSequence>(sequence))
                                                
                                                // get first track
                                                if let track = SequenceGetTrackByIndex(sequence, 0) {
                                                    
                                                    // get track length
                                                    if let trackLength = TrackGetLength(track) {
                                                        
                                                        // TODO remove this from UI thread
                                                        while (true) {
//                                                            sleep(1)
                                                            println(trackLength)
                                                            var now = PlayerGetTime(player)
                                                            if (now >= trackLength) {
                                                                break
                                                            }
                                                        }
                                                        
                                                        PlayerStop(player)
                                                        SequenceDispose(sequence)
                                                        PlayerDispose(player)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private class func loadSequence() -> MusicSequence? {
        let fileURL = NSBundle.mainBundle().URLForResource("simpletest", withExtension: "mid")
        return SequenceLoadFromFile(fileURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

