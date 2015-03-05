//
//  ViewController.swift
//  MIDI
//
//  Created by Student on 2/25/15.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var btnCreateSequence: UIButton!
    
    @IBAction func createSequence(sender: AnyObject) {
        let fileURL = NSBundle.mainBundle().URLForResource("bossanuevewext", withExtension: "mid")
        var sequence = MusicSequenceWrapper(url: fileURL)
        if sequence == nil {
            println("Sequence Failed To Load")
            return
        }
        println("Starting Transposition")
        sequence!.transposeAllTracks(2)
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

