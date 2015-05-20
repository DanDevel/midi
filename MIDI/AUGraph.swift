//
//  AUGraph.swift
//  MIDI
//
//  Created by Student on 4/6/15.
//
//

import AudioToolbox

var GMDict:[String:UInt8] = [
    "Acoustic Grand Piano" : 0,
    "Bright Acoustic Piano" : 1,
    "Electric Grand Piano" : 2,
    "Honky-tonk Piano" : 3,
    "Electric Piano 1" : 4,
    "Electric Piano 2" : 5,
    "Harpsichord" : 6,
    "Clavi" : 7,
    "Celesta" : 8,
    "Glockenspiel" : 9,
    "Music Box" : 10,
    "Vibraphone" : 11,
    "Marimba" : 12,
    "Xylophone" : 13,
    "Tubular Bells" : 14,
    "Dulcimer" : 15,
    "Drawbar Organ" : 16,
    "Percussive Organ" : 17,
    "Rock Organ" : 18,
    "ChurchPipe" : 19,
    "Positive" : 20,
    "Accordion" : 21,
    "Harmonica" : 22,
    "Tango Accordion" : 23,
    "Classic Guitar" : 24,
    "Acoustic Guitar" : 25,
    "Jazz Guitar" : 26,
    "Clean Guitar" : 27,
    "Muted Guitar" : 28,
    "Overdriven Guitar" : 29,
    "Distortion Guitar" : 30,
    "Guitar harmonics" : 31,
    "JazzBass" : 32,
    "DeepBass" : 33,
    "PickBass" : 34,
    "FretLess" : 35,
    "SlapBass1" : 36,
    "SlapBass2" : 37,
    "SynthBass1" : 38,
    "SynthBass2" : 39,
    "Violin" : 40,
    "Viola" : 41,
    "Cello" : 42,
    "ContraBass" : 43,
    "TremoloStr" : 44,
    "Pizzicato" : 45,
    "Harp" : 46,
    "Timpani" : 47,
    "String Ensemble 1" : 48,
    "String Ensemble 2" : 49,
    "SynthStrings 1" : 50,
    "SynthStrings 2" : 51,
    "Choir" : 52,
    "DooVoice" : 53,
    "Voices" : 54,
    "OrchHit" : 55,
    "Trumpet" : 56,
    "Trombone" : 57,
    "Tuba" : 58,
    "MutedTrumpet" : 59,
    "FrenchHorn" : 60,
    "Brass" : 61,
    "SynBrass1" : 62,
    "SynBrass2" : 63,
    "SopranoSax" : 64,
    "AltoSax" : 65,
    "TenorSax" : 66,
    "BariSax" : 67,
    "Oboe" : 68,
    "EnglishHorn" : 69,
    "Bassoon" : 70,
    "Clarinet" : 71,
    "Piccolo" : 72,
    "Flute" : 73,
    "Recorder" : 74,
    "PanFlute" : 75,
    "Bottle" : 76,
    "Shakuhachi" : 77,
    "Whistle" : 78,
    "Ocarina" : 79,
    "SquareWave" : 80,
    "SawWave" : 81,
    "Calliope" : 82,
    "SynChiff" : 83,
    "Charang" : 84,
    "AirChorus" : 85,
    "fifths" : 86,
    "BassLead" : 87,
    "New Age" : 88,
    "WarmPad" : 89,
    "PolyPad" : 90,
    "GhostPad" : 91,
    "BowedGlas" : 92,
    "MetalPad" : 93,
    "HaloPad" : 94,
    "Sweep" : 95,
    "IceRain" : 96,
    "SoundTrack" : 97,
    "Crystal" : 98,
    "Atmosphere" : 99,
    "Brightness" : 100,
    "Goblin" : 101,
    "EchoDrop" : 102,
    "SciFi effect" : 103,
    "Sitar" : 104,
    "Banjo" : 105,
    "Shamisen" : 106,
    "Koto" : 107,
    "Kalimba" : 108,
    "Scotland" : 109,
    "Fiddle" : 110,
    "Shanai" : 111,
    "MetalBell" : 112,
    "Agogo" : 113,
    "SteelDrums" : 114,
    "Woodblock" : 115,
    "Taiko" : 116,
    "Tom" : 117,
    "SynthTom" : 118,
    "RevCymbal" : 119,
    "FretNoise" : 120,
    "NoiseChiff" : 121,
    "Seashore" : 122,
    "Birds" : 123,
    "Telephone" : 124,
    "Helicopter" : 125,
    "Stadium" : 126,
    "GunShot" : 127
]


// Create an AUGraph that handles MIDI file input
func NewMIDIGraph(fontfile: String, sequence: MusicSequence) -> AUGraph? {
    // create new graph
    var graph = NewGraph()
    if let graph = graph {
        
        // add sampler node to graph
        let samplerNode = GraphAddSamplerNode(graph)
        if let samplerNode = samplerNode {
            
            // add io node to graph
            let ioNode = GraphAddIONode(graph)
            if let ioNode = ioNode {
                
                // open the graph
                if GraphOpen(graph) {
                    
                    // connect the sampler and io node
                    if GraphConnectNodes(graph, samplerNode, 0, ioNode, 0) {
                        
                        // initialize the graph
                        if GraphInitialize(graph) {
                            
                            // get reference to sampler unit
                            if let samplerUnit = GraphGetAudioUnit(graph, samplerNode) {
                                
                                // add sound font to sampler unit
                                if GraphAddSoundFontToAudioUnit(fontfile, 105, samplerUnit) {
                                
                                    // associate the sequence with the graph
                                    if SequenceSetAUGraph(sequence, graph) {
                                    
                                        if GraphStart(graph) {
                                            return graph
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
    return nil
}

// Returns a new AUGraph
func NewGraph() -> AUGraph? {
    var graph = AUGraph()
    let status = NewAUGraph(&graph)
    if status != noErr {
        println("Failed to create new graph")
        return nil
    }
    return graph
}

// Returns the added node
func GraphAddNode(graph: AUGraph, inout componentDesc: AudioComponentDescription, inout node: AUNode) -> AUNode? {
    let status = AUGraphAddNode(graph, &componentDesc, &node)
    if status != noErr {
        println("Could not add node to graph")
        return nil
    }
    return node;
}

// Adds a Sampler node to the AUGraph
func GraphAddSamplerNode(graph: AUGraph) -> AUNode? {
    var componentDesc = AudioComponentDescription(
        componentType: OSType(kAudioUnitType_MusicDevice),
        componentSubType: OSType(kAudioUnitSubType_Sampler),
        componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
        componentFlags: 0,
        componentFlagsMask: 0)
    var samplerNode = AUNode()
    
    return GraphAddNode(graph, &componentDesc, &samplerNode)
}

// Adds an IO node to the AUGraph
func GraphAddIONode(graph: AUGraph) -> AUNode? {
    var componentDesc = AudioComponentDescription(
        componentType: OSType(kAudioUnitType_Output),
        componentSubType: OSType(kAudioUnitSubType_RemoteIO),
        componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
        componentFlags: 0,
        componentFlagsMask: 0)
    var ioNode = AUNode()
    
    return GraphAddNode(graph, &componentDesc, &ioNode)
}

// Get a node by index from the AUGraph
func GraphGetNode(graph: AUGraph, index: UInt32) -> AUNode? {
    var node = AUNode()
    let status = AUGraphGetIndNode(graph, index, &node)
    if status != noErr {
        println("Failed to get node")
        return nil
    }
    return node
}

// Get the AudioUnit from the Node
func GraphGetAudioUnit(graph: AUGraph, node: AUNode) -> AudioUnit? {
    var audioUnit = AudioUnit()
    let status = AUGraphNodeInfo(graph, node, nil, &audioUnit)
    if status != noErr {
        println("Could not get audio unit")
        return nil
    }
    return audioUnit
}

// Connect two AUNodes
func GraphConnectNodes(graph: AUGraph, sourceNode: AUNode, sourceOutputNumber: UInt32, destNode: AUNode, destOutputNumber: UInt32) -> Bool {
    let status = AUGraphConnectNodeInput(graph, sourceNode, sourceOutputNumber, destNode, destOutputNumber)
    if status != noErr {
        println("Could not connect nodes")
        return false
    }
    return true
}

// Open the Graph
func GraphOpen(graph: AUGraph) -> Bool {
    let status = AUGraphOpen(graph)
    if status != noErr {
        println("Could not open graph")
        return false
    }
    return true
}

// Start the Graph
// Fix Implementation -> should there be a return value?
func GraphStart(graph: AUGraph) -> Bool {
    GraphInitialize(graph)
    if !GraphIsRunning(graph) {
        let status = AUGraphStart(graph)
        if status != noErr {
            println("Could not start graph")
            return false
        }
        return true
    }
    return true
}

// Initialize the Graph
// Fix Implementation -> should there be a return value?
func GraphInitialize(graph: AUGraph) -> Bool {
    if !GraphIsInitalized(graph) {
        let status = AUGraphInitialize(graph)
        if status != noErr {
            println("Could not initalize graph")
            return false
        }
        return true
    }
    return false
}

// Check if the graph is initalize
func GraphIsInitalized(graph: AUGraph) -> Bool {
    var isInitialized = Boolean()
    let status = AUGraphIsInitialized(graph, &isInitialized)
    if status != noErr {
        println("Could not check if graph was initialized")
        return false
    }
    return isInitialized != 0
}

// Check if the graph is running
func GraphIsRunning(graph: AUGraph) -> Bool {
    var isRunning = Boolean()
    let status = AUGraphIsRunning(graph, &isRunning)
    if status != noErr {
        println("Could not check is graph was running")
        return false
    }
    return isRunning != 0
}

// TODO: add preset param
// Add Sound Font to Audio Unit
func GraphAddSoundFontToAudioUnit(filename: String, preset: UInt8, unit: AudioUnit) -> Bool {
    if let url = NSBundle.mainBundle().URLForResource(filename, withExtension: "sf2") {
        var instrumentData = AUSamplerInstrumentData(
            fileURL: Unmanaged.passUnretained(url),
            instrumentType: UInt8(kInstrumentType_DLSPreset),
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB),
            presetID: preset)
        
        let status = AudioUnitSetProperty(
            unit,
            UInt32(kAUSamplerProperty_LoadInstrument),
            UInt32(kAudioUnitScope_Global),
            0,
            &instrumentData,
            UInt32(sizeof(AUSamplerInstrumentData)))
        
        if status != noErr {
            println("Could not add sound font")
            return false
        }
        return true
    }
    return false
}