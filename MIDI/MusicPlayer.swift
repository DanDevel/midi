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

func NewPlayerWithSequence(sequence: MusicSequence) -> MusicPlayer? {
    if let player = NewPlayer() {
        if PlayerSetSequence(player, sequence) {
            return player
        }
    }
    return nil
}

func PlayerIsPlaying(player: MusicPlayer) -> Bool {
    var playing = Boolean()
    let status = MusicPlayerIsPlaying(player, &playing)
    if status != noErr {
        println("Could not check if music player is playing")
        return false
    }
    return playing != 0
}

func PlayerGetTime(player: MusicPlayer) -> MusicTimeStamp? {
    var time = MusicTimeStamp()
    let status = MusicPlayerGetTime(player, &time)
    if status != noErr {
        println("Could not get player time")
        return nil
    }
    return time
}

func PlayerSetTime(player: MusicPlayer, time: MusicTimeStamp) -> Bool {
    let status = MusicPlayerSetTime(player, time)
    if status != noErr {
        println("could not set time")
        return false
    }
    return true
}

func PlayerResetTime(player: MusicPlayer) -> Bool {
    return PlayerSetTime(player, 0)
}

func PlayerPlayFromBeginning(player: MusicPlayer) -> Bool{
    if PlayerIsPlaying(player) {
        if !PlayerStop(player) {
            return false
        }
    }
    if PlayerResetTime(player) {
        return PlayerStart(player)
    }
    return false
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