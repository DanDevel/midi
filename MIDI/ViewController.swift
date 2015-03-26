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
        var sequence = SequenceLoadFromFile(fileURL)

        if let sequence = sequence {
            // print untransposed track
            CAShow(UnsafeMutablePointer<MusicTrack>(SequenceGetTrackByIndex(sequence, 1)!))
            // transpose track
            let transposedTrack = TransposeTrack(sequence, 1, 2)
            // print transposed track
            CAShow(UnsafeMutablePointer<MusicTrack>(transposedTrack!))
        }
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

