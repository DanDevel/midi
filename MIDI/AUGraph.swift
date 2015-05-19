//
//  AUGraph.swift
//  MIDI
//
//  Created by Student on 4/6/15.
//
//

import AudioToolbox

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
                                if GraphAddSoundFontToAudioUnit(fontfile, samplerUnit) {
                                
                                    // associate the sequence with the graph
                                    if SequenceSetAUGraph(sequence, graph) {
                                    
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
    return nil
}

//// Create an AUGraph that handles MIDI file input
//func NewMIDIGraph() -> AUGraph? {
//    // create new graph
//    var graph = NewGraph()
//    if let graph = graph {
//        
//        // add sampler node to graph
//        let samplerNode = GraphAddSamplerNode(graph)
//        if let samplerNode = samplerNode {
//            
//            // add io node to graph
//            let ioNode = GraphAddIONode(graph)
//            if let ioNode = ioNode {
//                
//                // open the graph
//                if GraphOpen(graph) {
//                    
//                    // connect the sampler and io node
//                    if GraphConnectNodes(graph, samplerNode, 0, ioNode, 0) {
//                        
//                        // initialize the graph
//                        if GraphInitialize(graph) {
//                            return graph
//                        }
//                    }
//                }
//            }
//        }
//    }
//    return nil
//}

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
    return false
}

// Initialize the Graph
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
func GraphAddSoundFontToAudioUnit(filename: String, unit: AudioUnit) -> Bool {
    if let url = NSBundle.mainBundle().URLForResource("piano", withExtension: "sf2") {
        var instrumentData = AUSamplerInstrumentData(
            fileURL: Unmanaged.passUnretained(url),
            instrumentType: UInt8(kInstrumentType_DLSPreset),
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB),
            presetID: 0)
        
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