//
//  AUGraph.swift
//  MIDI
//
//  Created by Student on 4/6/15.
//
//

import AudioToolbox


func NewGraph() -> AUGraph? {
    var graph = AUGraph()
    let status = NewAUGraph(&graph)
    if status != noErr {
        println("Failed to create new graph")
        return nil
    }
    return graph
}

func GraphAddNode(graph: AUGraph, inout componentDesc: AudioComponentDescription, inout node: AUNode) -> AUNode? {
    let status = AUGraphAddNode(graph, &componentDesc, &node)
    if status != noErr {
        println("Could not add node to graph")
        return nil
    }
    return node;
}

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

func GraphOpen(graph: AUGraph) -> Bool {
    let status = AUGraphOpen(graph)
    if status != noErr {
        println("Could not open graph")
        return false
    }
    return true
}

func GraphGetAudioUnit(graph: AUGraph, node: AUNode) -> AudioUnit? {
    var audioUnit = AudioUnit()
    let status = AUGraphNodeInfo(graph, node, nil, &audioUnit)
    if status != noErr {
        println("Could not get audio unit")
        return nil
    }
    return audioUnit
}

func GraphConnectNodes(graph: AUGraph, sourceNode: AUNode, sourceOutputNumber: UInt32, destNode: AUNode, destOutputNumber: UInt32) -> Bool {
    let status = AUGraphConnectNodeInput(graph, sourceNode, sourceOutputNumber, destNode, destOutputNumber)
    if status != noErr {
        println("Could not connect nodes")
        return false
    }
    return true
}

func GraphIsInitalized(graph: AUGraph) -> Bool {
    var isInitialized = Boolean()
    let status = AUGraphIsInitialized(graph, &isInitialized)
    if status != noErr {
        println("Could not check if graph was initialized")
        return false
    }
    return isInitialized == 0
}

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

func GraphIsRunning(graph: AUGraph) -> Bool {
    var isRunning = Boolean()
    let status = AUGraphIsRunning(graph, &isRunning)
    if status != noErr {
        println("Could not check is graph was running")
        return false
    }
    return isRunning == 0
}

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