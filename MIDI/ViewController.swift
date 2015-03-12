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

    @IBOutlet var btnCreateSequence: UIButton!
    
    @IBAction func createSequence(sender: AnyObject) {
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        // load sequence from file
        var sequence = MusicSequenceWrapper(url: fileURL)
        if sequence == nil {
            println("Sequence Failed To Load")
            return
        }
        
        // create transposer
        var transposer = MusicSequenceTransposer(sequence: sequence!)
        
        
        // print original sequence
//        var raw_sequence = sequence!.getSequence()
//        CAShow(&sequence)
        
        // transpose
        var track = transposer.transposeTrack(1, dNote: 2)!
        
        // print transposed track
        CAShow(UnsafeMutablePointer<MusicTrack>(track))
        
        // transpose
        track = transposer.transposeTrack(1, dNote: 1)!
        
        // print transposed track
        CAShow(UnsafeMutablePointer<MusicTrack>(track))
        
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

