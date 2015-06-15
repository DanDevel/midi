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
        var data: AUNode
        var unit: AudioUnit
        var track: Int
        
        init(name: String, data: AUNode, unit: AudioUnit, track: Int) {
            self.name = name
            self.data = data
            self.unit = unit
            self.track = track
        }
        
    }
    
    private var graph: AUGraph?
    private var soundfontFile = "GeneralUser GS MuseScore v1.442"
    
    private var samplerNodes = Array<Node>()
    private var ioNode: Node?
    private var mixerNode: Node?
    
    private var sequence: MusicSequence?
    
    let soundfontPresets: [String: UInt8] = [
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
        ENTRY_LOG()
        setGraph(newGraph()!)
        setIONode(addIONode())
        CAShow(UnsafeMutablePointer<Void>(self.graph!))
        EXIT_LOG()
    }
    
    init(sequence: MusicSequence) {
        ENTRY_LOG()
        self.sequence = sequence
        setGraph(newGraph()!)
        
        open()
        
        addSamplerNode("Piano", trackIndex: 0)
        addSamplerNode("Bass", trackIndex: 1)
        addSamplerNode("Drums", trackIndex: 2)
        
        setMixerNode(addMixerNode())
        setIONode(addIONode())
        
        var numBuses = UInt32(3)
        let numBusesSize = UInt32(sizeofValue(numBuses))
        AudioUnitSetProperty(
            mixerNode!.unit,
            AudioUnitPropertyID(kAudioUnitProperty_ElementCount),
            AudioUnitScope(kAudioUnitScope_Input),
            0,
            &numBuses,
            numBusesSize)
        
        connectNodes(samplerNodes[0].data, sourceOutputNumber: 0, destNode: mixerNode!.data, destOutputNumber: 0) // input node instead
        connectNodes(samplerNodes[1].data, sourceOutputNumber: 0, destNode: mixerNode!.data, destOutputNumber: 1)
        connectNodes(samplerNodes[2].data, sourceOutputNumber: 0, destNode: mixerNode!.data, destOutputNumber: 2)
        
        connectNodes(mixerNode!.data, sourceOutputNumber: 0, destNode: ioNode!.data, destOutputNumber: 0)
        
        
        SequenceSetAUGraph(sequence, self.graph!)
        
        
        addSoundFontToNode(samplerNodes[0])
        addSoundFontToNode(samplerNodes[1])
        addSoundFontToNode(samplerNodes[2])
        
        var track = SequenceGetTrackByIndex(sequence, 0)!
        TrackSetDestNode(track, samplerNodes[0].data)  // input Node instead
        
        track = SequenceGetTrackByIndex(sequence, 1)!
        TrackSetDestNode(track, samplerNodes[1].data)
        
        track = SequenceGetTrackByIndex(sequence, 2)!
        TrackSetDestNode(track, samplerNodes[2].data)
        
        
        
        var t = SequenceGetLastTrack(sequence)!
        var iterator = NewIterator(t)!
        var events = IteratorGetMetaEvents(iterator)
        for var i = 1; i < events.count; i+=2 {
            MetaEventGetContent(events[i])
        }
        EXIT_LOG()
    }
    
//    init(sequence: MusicSequence) {
//        
//        setGraph(newGraph()!)
//        open()
//        SequenceSetAUGraph(sequence, self.graph!)
//        setIONode(addIONode("IO", bus: 0))
//        AudioUnitInitialize(self.ioNode!.unit)
//        
//        var track = SequenceGetLastTrack(sequence)!
//        var iterator = NewIterator(track)!
//        var events = IteratorGetMetaEvents(iterator)
//        var bus: UInt32 = 0
//        var t: UInt32 = 0
//        for var i = 1; i < events.count; i+=2 {
//            addInstrument(MetaEventGetContent(events[i]), bus: bus, track: SequenceGetTrackByIndex(sequence, t)!)
//            bus++
//            t++
//        }
//        
//        GraphInitialize(self.graph!)
//        
////        //abstract this
////        var sampleRate: Float64 = 44_100
////        let sampleRateSize = UInt32(sizeofValue(sampleRate))
////        var result = AudioUnitSetProperty(
////            self.ioNode!.unit,
////            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
////            AudioUnitScope(kAudioUnitScope_Input),
////            0,
////            &sampleRate,
////            sampleRateSize)
////        log.debug("RESULT io: \(result)")
////        result = AudioUnitSetProperty(
////            self.ioNode!.unit,
////            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
////            AudioUnitScope(kAudioUnitScope_Input),
////            2,
////            &sampleRate,
////            sampleRateSize)
////        log.debug("RESULT io: \(result)")
////        result = AudioUnitSetProperty(
////            self.ioNode!.unit,
////            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
////            AudioUnitScope(kAudioUnitScope_Input),
////            1,
////            &sampleRate,
////            sampleRateSize)
////        log.debug("RESULT io: \(result)")
////        result = AudioUnitSetProperty(
////            self.ioNode!.unit,
////            AudioUnitPropertyID(kAudioUnitProperty_SampleRate),
////            AudioUnitScope(kAudioUnitScope_Output),
////            0,
////            &sampleRate,
////            sampleRateSize)
////        log.debug("RESULT samp: \(result)")
//        
//        
//        
//        
//        
//        CAShow(UnsafeMutablePointer<Void>(self.graph!))
//    }
    
    private func setGraph(graph: AUGraph) {
        ENTRY_LOG()
        EXIT_LOG()
        self.graph = graph
    }
    
    private func newGraph() -> AUGraph? {
        ENTRY_LOG()
        var graph = AUGraph()
        let status = NewAUGraph(&graph)
        if status != noErr {
            log.error("Failed to create new graph")
            EXIT_LOG()
            return nil
        }
        log.info("New graph created")
        EXIT_LOG()
        return graph
    }
    
    // Returns the added node
    private func addNode(inout componentDesc: AudioComponentDescription, inout node: AUNode) -> AUNode? {
        ENTRY_LOG()
        let status = AUGraphAddNode(self.graph!, &componentDesc, &node)
        if status != noErr {
            log.error("Could not add node to graph")
            EXIT_LOG()
            return nil
        }
        log.info("New node added")
        EXIT_LOG()
        return node
    }
    
//    func addInstrument(name: String, bus: UInt32, track: MusicTrack) {
//        log.error("Adding Instrument...")
//        var node = addSamplerNode(name)
//        connectNodes(node.data, sourceOutputNumber: node.bus, destNode: self.ioNode!.data, destOutputNumber: bus)
//        addSoundFontToAudioUnit(UInt8(soundfontPresets[node.name]!), unit: node.unit)
//        MusicTrackSetDestNode(track, node.data)
//        log.error("Instrument added.")
//    }
    
    // Adds a Sampler node to the AUGraph
    private func addSamplerNode(name: String, trackIndex: Int) -> Node {
        ENTRY_LOG()
        log.info("Adding sampler node")
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_Sampler),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var samplerNodeData = AUNode()
        addNode(&componentDesc, node: &samplerNodeData)
        
        var samplerNodeUnit = getAudioUnit(samplerNodeData)!
        
        // TODO abstract this
        var n = name
        if n == "Piano" {
            n = "Acoustic Grand Piano"
        } else if n == "Bass" {
            n = "JazzBass"
        } else if n == "Drums" {
            n = "Acoustic Grand Piano"
        }
        
        log.debug("NAME: \(name)")
        log.debug("INSTRUMENT TYPE: \(n)")
        log.debug("TRACK: \(trackIndex)")
        log.debug("NODE: \(samplerNodeData.description)")
        
        var samplerNode = Node(name: n, data: samplerNodeData, unit: samplerNodeUnit, track: trackIndex)
        
        self.samplerNodes.append(samplerNode)
        log.info("Sampler node added")
        EXIT_LOG()
        return samplerNode
    }
    
    // Get a node by index from the AUGraph
    func getSamplerNodes() -> Array<Node> {
        ENTRY_LOG()
        EXIT_LOG()
        return self.samplerNodes
    }
    
    // TODO overwrite current IO node?
    private func addIONode() -> Node {
        ENTRY_LOG()
        log.info("Adding IO node")
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var ioNodeData = AUNode()
        addNode(&componentDesc, node: &ioNodeData)
        
        var ioNodeUnit = getAudioUnit(ioNodeData)!
        
        log.info("IO node added")
        EXIT_LOG()
        return Node(name: "IO", data: ioNodeData, unit: ioNodeUnit, track: -1)
    }
    
    // Adds an IO node to the AUGraph
    private func setIONode(node: Node) {
        ENTRY_LOG()
        EXIT_LOG()
        self.ioNode = node
    }

    func getIONode() -> Node {
        ENTRY_LOG()
        EXIT_LOG()
        return self.ioNode!
    }
    
    // TODO overwrite current Mixer node?
    private func addMixerNode() -> Node {
        ENTRY_LOG()
        log.info("Adding Mixer Node")
        var componentDesc = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Mixer),
            componentSubType: OSType(kAudioUnitSubType_MultiChannelMixer),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        var mixerNodeData = AUNode()
        addNode(&componentDesc, node: &mixerNodeData)
        
        var mixerNodeUnit = getAudioUnit(mixerNodeData)!
        
        log.info("Mixer node added")
        EXIT_LOG()
        return Node(name: "Mixer", data: mixerNodeData, unit: mixerNodeUnit, track: -1)
    }
    
    private func setMixerNode(node: Node) {
        ENTRY_LOG()
        EXIT_LOG()
        self.mixerNode = node
    }
    
    func getMixerNode() -> Node {
        ENTRY_LOG()
        EXIT_LOG()
        return self.mixerNode!
    }

    // Get the AudioUnit from the Node
    func getAudioUnit(node: AUNode) -> AudioUnit? {
        ENTRY_LOG()
        var audioUnit = AudioUnit()
        let status = AUGraphNodeInfo(self.graph!, node, nil, &audioUnit)
        if status != noErr {
            log.error("Could not get audio unit")
            EXIT_LOG()
            return nil
        }
        log.info("Audio unit retrieved")
        EXIT_LOG()
        return audioUnit
    }
    
    // Connect two AUNodes
    func connectNodes(sourceNode: AUNode, sourceOutputNumber: UInt32, destNode: AUNode, destOutputNumber: UInt32) -> Bool {
        ENTRY_LOG()
        let status = AUGraphConnectNodeInput(self.graph!, sourceNode, sourceOutputNumber, destNode, destOutputNumber)
        log.debug("Connecting src \(sourceOutputNumber) to dest \(destOutputNumber). status: \(status)")
        if status != noErr {
            log.error("Could not connect nodes")
            EXIT_LOG()
            return false
        }
        log.info("Nodes connected")
        EXIT_LOG()
        return true
    }
    
    // Open the Graph
    // Fix Implementation -> should there be a return value?
    func open() -> Bool {
        ENTRY_LOG()
        let status = AUGraphOpen(self.graph!)
        if status != noErr {
            log.error("Could not open graph")
            EXIT_LOG()
            return false
        }
        log.info("Graph opened")
        EXIT_LOG()
        return true
    }
    
    // Start the Graph
    // Fix Implementation -> should there be a return value?
    func start() -> Bool {
        ENTRY_LOG()
        initialize()
        if !isRunning() {
            let status = AUGraphStart(self.graph!)
            if status != noErr {
                log.error("Could not start graph")
                EXIT_LOG()
                return false
            }
            log.info("Graph started")
            EXIT_LOG()
            return true
        }
        log.warning("Graph already started")
        EXIT_LOG()
        return true
    }
    
    // Initialize the Graph
    // Fix Implementation -> should there be a return value?
    func initialize() -> Bool {
        ENTRY_LOG()
        if !isInitalized() {
            let status = AUGraphInitialize(self.graph!)
            if status != noErr {
                log.error("Could not initalize graph")
                EXIT_LOG()
                return false
            }
            log.info("Graph initialized")
            EXIT_LOG()
            return true
        }
        log.warning("Graph already initialized")
        EXIT_LOG()
        return false
    }
    
    // Check if the graph is initalize
    func isInitalized() -> Bool {
        ENTRY_LOG()
        var isInitialized = Boolean()
        let status = AUGraphIsInitialized(self.graph!, &isInitialized)
        if status != noErr {
            log.error("Could not check if graph was initialized")
            EXIT_LOG()
            return false
        }
        EXIT_LOG()
        return isInitialized != 0
    }
    
    // Check if the graph is running
    func isRunning() -> Bool {
        ENTRY_LOG()
        var isRunning = Boolean()
        let status = AUGraphIsRunning(self.graph!, &isRunning)
        if status != noErr {
            log.error("Could not check is graph was running")
            EXIT_LOG()
            return false
        }
        EXIT_LOG()
        return isRunning != 0
    }
    
    // TODO: add preset param
    // Add Sound Font to Audio Unit
    private func addSoundFontToNode(node: Node) -> Bool {
        ENTRY_LOG()
        let preset = soundfontPresets[node.name]!
        let unit = node.unit
        var bank = UInt8(kAUSampler_DefaultMelodicBankMSB)
        if TrackIsDrum(SequenceGetTrackByIndex(self.sequence!, UInt32(node.track))!) {
            bank = UInt8(kAUSampler_DefaultPercussionBankMSB)
        }
        log.debug("Soundbank \(bank)")
        if let url = NSBundle.mainBundle().URLForResource(self.soundfontFile, withExtension: "sf2") {
            
            
            var instrumentData = AUSamplerInstrumentData(
                fileURL: Unmanaged.passUnretained(url),
                instrumentType: UInt8(kInstrumentType_DLSPreset),
                bankMSB: bank,
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
                log.error("Could not add sound font")
                EXIT_LOG()
                return false
            }
            
            log.debug("Sound font preset \(preset) added to \(unit.debugDescription)")
            EXIT_LOG()
            return true
        }
        log.error("Unable to get sound font URL")
        EXIT_LOG()
        return false
    }
    
}
