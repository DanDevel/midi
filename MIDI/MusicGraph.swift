//
//  MusicGraph.swift
//  MIDI
//
//  Created by Student on 5/20/15.
//
//

import AudioToolbox

class MusicGraph {
    
    
    struct Node {
        var name: String
        var bus: UInt32
        var data: AUNode
        var unit: AudioUnit
        
        init(name: String, bus: UInt32, data: AUNode, unit: AudioUnit) {
            self.name = name
            self.bus = bus
            self.data = data
            self.unit = unit
        }
        
    }
    
    private var graph: AUGraph?
    private var soundfontFile = "GeneralUser GS MuseScore v1.442"
    
    private var samplerNodes = Array<Node>()
    private var ioNode: Node?
    
    let soundfontPresets = [
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
    
    init() {
        setGraph(newGraph()!)
        setIONode("IO", bus: 0)
    }
    
    init(sequence: MusicSequence) {
        
    }
    
    private func setGraph(graph: AUGraph) {
        self.graph = graph
    }
    
    private func newGraph() -> AUGraph? {
        var graph = AUGraph()
        let status = NewAUGraph(&graph)
        if status != noErr {
            println("Failed to create new graph")
            return nil
        }
        return graph
    }
    
    // Returns the added node
    private func addNode(inout componentDesc: AudioComponentDescription, inout node: AUNode) -> AUNode? {
        let status = AUGraphAddNode(self.graph!, &componentDesc, &node)
        if status != noErr {
            println("Could not add node to graph")
            return nil
        }
        return node;
    }
    
    func addInstrument(name: String) {
        var node = addSamplerNode(name)
        connectNodes(node.data, sourceOutputNumber: node.bus, destNode: self.ioNode!.data, destOutputNumber: self.ioNode!.bus)
    }
    
    // Adds a Sampler node to the AUGraph
    private func addSamplerNode(name: String) -> Node {
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_Sampler),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var samplerNodeData = AUNode()
        addNode(&componentDesc, node: &samplerNodeData)
        
        var samplerNodeUnit = getAudioUnit(samplerNodeData)!
        
        var samplerNode = Node(name: name, bus: 0, data: samplerNodeData, unit: samplerNodeUnit)
        
        self.samplerNodes.append(samplerNode)
        return samplerNode
    }
    
    // Get a node by index from the AUGraph
    func getSamplerNodes() -> Array<Node> {
        return self.samplerNodes
    }
    
    // Adds an IO node to the AUGraph
    private func setIONode(name: String, bus: UInt32) {
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var ioNodeData = AUNode()
        addNode(&componentDesc, node: &ioNodeData)
        
        var ioNodeUnit = getAudioUnit(ioNodeData)!
        
        self.ioNode = Node(name: name, bus: bus, data: ioNodeData, unit: ioNodeUnit)
    }

    func getIONode() -> Node {
        return self.ioNode!
    }

    // Get the AudioUnit from the Node
    func getAudioUnit(node: AUNode) -> AudioUnit? {
        var audioUnit = AudioUnit()
        let status = AUGraphNodeInfo(self.graph!, node, nil, &audioUnit)
        if status != noErr {
            println("Could not get audio unit")
            return nil
        }
        return audioUnit
    }
    
    // Connect two AUNodes
    func connectNodes(sourceNode: AUNode, sourceOutputNumber: UInt32, destNode: AUNode, destOutputNumber: UInt32) -> Bool {
        let status = AUGraphConnectNodeInput(self.graph!, sourceNode, sourceOutputNumber, destNode, destOutputNumber)
        if status != noErr {
            println("Could not connect nodes")
            return false
        }
        return true
    }
    
    // Open the Graph
    // Fix Implementation -> should there be a return value?
    func open() -> Bool {
        let status = AUGraphOpen(self.graph!)
        if status != noErr {
            println("Could not open graph")
            return false
        }
        return true
    }
    
    // Start the Graph
    // Fix Implementation -> should there be a return value?
    func start() -> Bool {
        initialize()
        if !isRunning() {
            let status = AUGraphStart(self.graph!)
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
    func initialize() -> Bool {
        if !isInitalized() {
            let status = AUGraphInitialize(self.graph!)
            if status != noErr {
                println("Could not initalize graph")
                return false
            }
            return true
        }
        return false
    }
    
    // Check if the graph is initalize
    func isInitalized() -> Bool {
        var isInitialized = Boolean()
        let status = AUGraphIsInitialized(self.graph!, &isInitialized)
        if status != noErr {
            println("Could not check if graph was initialized")
            return false
        }
        return isInitialized != 0
    }
    
    // Check if the graph is running
    func isRunning() -> Bool {
        var isRunning = Boolean()
        let status = AUGraphIsRunning(self.graph!, &isRunning)
        if status != noErr {
            println("Could not check is graph was running")
            return false
        }
        return isRunning != 0
    }
    
    // TODO: add preset param
    // Add Sound Font to Audio Unit
    private func addSoundFontToAudioUnit(preset: UInt8, unit: AudioUnit) -> Bool {
        if let url = NSBundle.mainBundle().URLForResource(self.soundfontFile, withExtension: "sf2") {
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
    
}
