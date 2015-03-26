//
//  MusicPlayer.swift
//  MIDI
//
//  Created by Student on 3/26/15.
//
//

import AudioToolbox


func NewPlayer() -> MusicPlayer? {
    var player = MusicPlayer()
    let status = NewMusicPlayer(&player)
    
    if status != noErr {
        println("Failed to create new player")
        return nil
    }
    
    return player
}

func PlayerDispose(player: MusicPlayer) -> Bool {
    let status = DisposeMusicPlayer(player)
    
    if status != noErr {
        println("Failed to dispose of player")
        return false
    }
    
    return true
}

func PlayerSetSequence(player: MusicPlayer, sequence: MusicSequence) -> Bool {
    let status = MusicPlayerSetSequence(player, sequence)
    
    if status != noErr {
        println("Failed to set sequence")
        return false
    }
    
    return true
}

func PlayerStart(player: MusicPlayer) -> Bool {
    let status = MusicPlayerStart(player)
    
    if status != noErr {
        println("Failed to start player")
        return false
    }
    
    return true
}

func PlayerStop(player: MusicPlayer) -> Bool {
    let status = MusicPlayerStop(player)
    
    if status != noErr {
        println("Failed to stop player")
        return false
    }
    
    return true
}


// TODO add function for reseting, etc..