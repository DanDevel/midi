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
    
    private class func loadSequence() -> MusicSequence? {
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
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

